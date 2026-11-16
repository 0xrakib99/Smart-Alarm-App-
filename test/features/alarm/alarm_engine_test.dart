import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';

class FakeAlarmRepository implements AlarmRepository {
  final List<AlarmModel> _alarms = <AlarmModel>[];

  @override
  List<AlarmModel> getAlarms() => List<AlarmModel>.from(_alarms);

  @override
  Future<bool> saveAlarm(AlarmModel alarm) async {
    final index = _alarms.indexWhere((item) => item.id == alarm.id);
    if (index == -1) {
      _alarms.add(alarm);
    } else {
      _alarms[index] = alarm;
    }
    return true;
  }

  @override
  Future<bool> deleteAlarm(String id) async {
    _alarms.removeWhere((alarm) => alarm.id == id);
    return true;
  }

  @override
  Future<bool> setEnabled(String id, bool enabled) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index == -1) {
      return false;
    }
    _alarms[index] = _alarms[index].copyWith(enabled: enabled);
    return true;
  }
}

class FakeAlarmHistoryRepository implements AlarmHistoryRepository {
  final List<AlarmHistoryRecord> records = <AlarmHistoryRecord>[];

  @override
  List<AlarmHistoryRecord> getAll({bool newestFirst = true}) =>
      List<AlarmHistoryRecord>.from(records);

  @override
  AlarmHistoryRecord? getById(String id) => records
      .cast<AlarmHistoryRecord?>()
      .firstWhere((r) => r?.id == id, orElse: () => null);

  @override
  Future<bool> addRecord(AlarmHistoryRecord record) async {
    records.add(record);
    return true;
  }

  @override
  Future<bool> deleteRecord(String id) async {
    records.removeWhere((r) => r.id == id);
    return true;
  }

  @override
  Future<bool> clearHistory() async {
    records.clear();
    return true;
  }

  @override
  List<AlarmHistoryRecord> filter({
    DateTime? from,
    DateTime? to,
    AlarmHistoryStatus? status,
    bool newestFirst = true,
  }) => getAll(newestFirst: newestFirst);
}

class TestAlarmNativeService extends AlarmNativeService {
  final List<String> scheduledAlarms = <String>[];
  final List<String> cancelledAlarms = <String>[];
  bool isRingingStopped = false;
  bool isAudioPaused = false;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;

  @override
  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    scheduledAlarms.add(alarm.id);
    return true;
  }

  @override
  Future<bool> cancelAlarm(String id) async {
    cancelledAlarms.add(id);
    return true;
  }

  @override
  Future<bool> pauseRinging() async {
    pauseCalls++;
    isAudioPaused = true;
    return true;
  }

  @override
  Future<bool> resumeRinging() async {
    resumeCalls++;
    isAudioPaused = false;
    return true;
  }

  @override
  Future<bool> stopRinging() async {
    stopCalls++;
    isRingingStopped = true;
    isAudioPaused = false;
    return true;
  }

  @override
  Future<bool> snooze(String id, int snoozeMinutes) async {
    isRingingStopped = true;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getActiveAlarm() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAlarmRepository repository;
  late FakeAlarmHistoryRepository historyRepository;
  late TestAlarmNativeService nativeService;
  late AlarmStateService stateService;

  setUp(() {
    Get.testMode = true;
    repository = FakeAlarmRepository();
    historyRepository = FakeAlarmHistoryRepository();
    nativeService = TestAlarmNativeService();
    stateService = AlarmStateService(
      nativeService: nativeService,
      alarmRepository: repository,
      historyRepository: historyRepository,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('Alarm Engine & State Management', () {
    final sampleAlarm = AlarmModel(
      id: 'alarm_test_1',
      hour: 7,
      minute: 30,
      label: 'Wake Up',
      repeatDays: const <int>[1, 2, 3, 4, 5],
      soundId: 'default',
      vibrationEnabled: true,
      snoozeEnabled: true,
      snoozeMinutes: 10,
      enabled: true,
      createdAt: DateTime.now(),
      mission: const MissionConfig(
        type: MissionType.math,
        difficulty: MissionDifficulty.easy,
      ),
    );

    test('initial state is idle', () {
      expect(stateService.currentState.value, AlarmState.idle);
      expect(stateService.activeAlarm.value, isNull);
    });

    test(
      'handleTrigger transitions state to ringing and loads active alarm',
      () {
        stateService.handleTrigger(sampleAlarm.toMap());

        expect(stateService.currentState.value, AlarmState.ringing);
        expect(stateService.activeAlarm.value, isNotNull);
        expect(stateService.activeAlarm.value!.id, 'alarm_test_1');
      },
    );

    test(
      'mission completion keeps alarm ringing until explicit dismiss records history',
      () async {
        stateService.handleTrigger(sampleAlarm.toMap());

        final dummyResult = MissionResult(
          type: MissionType.math,
          difficulty: MissionDifficulty.easy,
          isSuccess: true,
          startedAt: DateTime.now().subtract(const Duration(seconds: 15)),
          completedAt: DateTime.now(),
        );

        await stateService.onMissionSuccess(dummyResult);

        expect(stateService.currentState.value, AlarmState.completed);
        expect(stateService.areMissionsCompleted.value, isTrue);
        expect(nativeService.isRingingStopped, isFalse);
        expect(nativeService.stopCalls, 0);
        expect(nativeService.resumeCalls, 1);
        expect(stateService.lastMissionResult.value, dummyResult);
        expect(historyRepository.records, isEmpty);

        // Only explicit Dismiss stops ringing and records history
        await stateService.finishAndDismiss();

        expect(nativeService.isRingingStopped, isTrue);
        expect(nativeService.stopCalls, 1);
        expect(stateService.currentState.value, AlarmState.idle);
        expect(stateService.activeAlarm.value, isNull);
        expect(historyRepository.records.length, 1);
        final record = historyRepository.records.first;
        expect(record.status, AlarmHistoryStatus.completed);
        expect(record.alarmId, 'alarm_test_1');
        expect(record.completedMissions, contains('math'));
      },
    );

    test(
      'one-time alarm is disabled only upon explicit dismiss after mission completion',
      () async {
        final oneTimeAlarm = sampleAlarm.copyWith(
          id: 'one_time_1',
          repeatDays: const <int>[],
        );
        await repository.saveAlarm(oneTimeAlarm);

        stateService.handleTrigger(oneTimeAlarm.toMap());

        final dummyResult = MissionResult(
          type: MissionType.math,
          difficulty: MissionDifficulty.easy,
          isSuccess: true,
          startedAt: DateTime.now().subtract(const Duration(seconds: 10)),
          completedAt: DateTime.now(),
        );

        await stateService.onMissionSuccess(dummyResult);
        expect(
          repository
              .getAlarms()
              .firstWhere((a) => a.id == 'one_time_1')
              .enabled,
          isTrue,
        );

        await stateService.finishAndDismiss();
        final updated = repository.getAlarms().firstWhere(
          (a) => a.id == 'one_time_1',
        );
        expect(updated.enabled, isFalse);
      },
    );

    test(
      'dismiss is rejected when required mission is not yet completed',
      () async {
        stateService.handleTrigger(sampleAlarm.toMap());
        expect(stateService.areMissionsCompleted.value, isFalse);

        await stateService.finishAndDismiss();

        expect(nativeService.isRingingStopped, isFalse);
        expect(nativeService.stopCalls, 0);
        expect(stateService.currentState.value, AlarmState.ringing);
        expect(stateService.activeAlarm.value, isNotNull);
        expect(historyRepository.records, isEmpty);
      },
    );

    test(
      'alarm with no mission still requires explicit dismiss to stop',
      () async {
        final noMissionAlarm = AlarmModel(
          id: 'alarm_no_mission',
          hour: sampleAlarm.hour,
          minute: sampleAlarm.minute,
          label: sampleAlarm.label,
          repeatDays: sampleAlarm.repeatDays,
          soundId: sampleAlarm.soundId,
          vibrationEnabled: sampleAlarm.vibrationEnabled,
          snoozeEnabled: sampleAlarm.snoozeEnabled,
          snoozeMinutes: sampleAlarm.snoozeMinutes,
          enabled: sampleAlarm.enabled,
          createdAt: sampleAlarm.createdAt,
          mission: null,
        );
        stateService.handleTrigger(noMissionAlarm.toMap());

        expect(nativeService.isRingingStopped, isFalse);
        await stateService.finishAndDismiss();

        expect(nativeService.isRingingStopped, isTrue);
        expect(stateService.currentState.value, AlarmState.idle);
      },
    );
  });
}
