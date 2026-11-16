import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/features/alarm/controllers/alarm_ringing_controller.dart';
import 'package:smart_alarm/features/alarm/presentation/alarm_ringing_screen.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';

class _FakeAlarmRepository implements AlarmRepository {
  final List<AlarmModel> _alarms = <AlarmModel>[];

  @override
  List<AlarmModel> getAlarms() => List<AlarmModel>.from(_alarms);

  @override
  Future<bool> saveAlarm(AlarmModel alarm) async {
    final idx = _alarms.indexWhere((a) => a.id == alarm.id);
    if (idx == -1) {
      _alarms.add(alarm);
    } else {
      _alarms[idx] = alarm;
    }
    return true;
  }

  @override
  Future<bool> deleteAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    return true;
  }

  @override
  Future<bool> setEnabled(String id, bool enabled) async {
    final idx = _alarms.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    _alarms[idx] = _alarms[idx].copyWith(enabled: enabled);
    return true;
  }
}

class _FakeHistoryRepository implements AlarmHistoryRepository {
  final List<AlarmHistoryRecord> records = <AlarmHistoryRecord>[];

  @override
  Future<bool> addRecord(AlarmHistoryRecord record) async {
    records.add(record);
    return true;
  }

  @override
  Future<bool> clearHistory() async {
    records.clear();
    return true;
  }

  @override
  Future<bool> deleteRecord(String id) async {
    records.removeWhere((r) => r.id == id);
    return true;
  }

  @override
  List<AlarmHistoryRecord> filter({
    DateTime? from,
    DateTime? to,
    AlarmHistoryStatus? status,
    bool newestFirst = true,
  }) => getAll(newestFirst: newestFirst);

  @override
  List<AlarmHistoryRecord> getAll({bool newestFirst = true}) =>
      List<AlarmHistoryRecord>.from(records);

  @override
  AlarmHistoryRecord? getById(String id) =>
      records.firstWhereOrNull((r) => r.id == id);
}

class _MockNativeService extends AlarmNativeService {
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;
  bool isSoundCurrentlyPlaying = true;
  final List<String> scheduledIds = <String>[];

  @override
  Future<bool> pauseRinging() async {
    pauseCalls++;
    isSoundCurrentlyPlaying = false;
    return true;
  }

  @override
  Future<bool> resumeRinging() async {
    resumeCalls++;
    isSoundCurrentlyPlaying = true;
    return true;
  }

  @override
  Future<bool> stopRinging() async {
    stopCalls++;
    isSoundCurrentlyPlaying = false;
    return true;
  }

  @override
  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    scheduledIds.add(alarm.id);
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getActiveAlarm() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final strictAlarm = AlarmModel(
    id: 'strict_1',
    hour: 6,
    minute: 45,
    label: 'Strict Morning Alarm',
    repeatDays: const <int>[1, 2, 3, 4, 5],
    soundId: 'siren',
    vibrationEnabled: true,
    snoozeEnabled: true,
    snoozeMinutes: 5,
    enabled: true,
    createdAt: DateTime(2026, 11, 12, 6, 0),
    mission: const MissionConfig(
      type: MissionType.math,
      difficulty: MissionDifficulty.medium,
    ),
  );

  late _FakeAlarmRepository alarmRepo;
  late _FakeHistoryRepository historyRepo;
  late _MockNativeService nativeService;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    alarmRepo = _FakeAlarmRepository();
    historyRepo = _FakeHistoryRepository();
    nativeService = _MockNativeService();
  });

  tearDown(() {
    Get.reset();
  });

  MissionResult buildSuccessResult(MissionType type) {
    final now = DateTime.now();
    return MissionResult(
      type: type,
      difficulty: MissionDifficulty.medium,
      isSuccess: true,
      startedAt: now.subtract(const Duration(seconds: 20)),
      completedAt: now,
    );
  }

  Widget buildStrictTestApp({required AlarmStateService stateService}) {
    Get.put<AlarmStateService>(stateService);
    return GetMaterialApp(
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      getPages: <GetPage<dynamic>>[
        GetPage<void>(
          name: AppRoutes.home,
          page: () => const Scaffold(body: Text('Home Screen')),
        ),
        GetPage<void>(
          name: AppRoutes.alarmRinging,
          page: () {
            Get.put(
              AlarmRingingController(
                alarmStateService: stateService,
                alarm: stateService.activeAlarm.value,
              ),
            );
            return const AlarmRingingScreen();
          },
        ),
        GetPage<MissionResult?>(
          name: AppRoutes.mathMission,
          page: () => const Scaffold(
            body: Column(
              children: <Widget>[
                MissionAlarmBanner(),
                Text('Math Mission Stub'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  group('Strict Alarm Mode — Core Rules & Timers', () {
    test(
      '1 & 2. Mission completion never stops alarm; sound stays active until Dismiss',
      () async {
        final service = AlarmStateService(
          nativeService: nativeService,
          alarmRepository: alarmRepo,
          historyRepository: historyRepo,
        );
        service.handleTrigger(strictAlarm.toMap());

        await service.onMissionSuccess(buildSuccessResult(MissionType.math));

        expect(service.areMissionsCompleted.value, isTrue);
        expect(service.currentState.value, AlarmState.completed);
        expect(service.activeAlarm.value?.id, 'strict_1');
        expect(nativeService.stopCalls, 0);
        expect(nativeService.resumeCalls, 1);
        expect(nativeService.isSoundCurrentlyPlaying, isTrue);
        expect(historyRepo.records, isEmpty);
      },
    );

    test('3. Rejects Dismiss before all required missions complete', () async {
      final service = AlarmStateService(
        nativeService: nativeService,
        alarmRepository: alarmRepo,
        historyRepository: historyRepo,
      );
      service.handleTrigger(strictAlarm.toMap());

      await service.finishAndDismiss();

      expect(nativeService.stopCalls, 0);
      expect(service.currentState.value, AlarmState.ringing);
      expect(service.activeAlarm.value, isNotNull);
    });

    test(
      '4. Explicit Dismiss after completion stops service, clears session & logs history',
      () async {
        final service = AlarmStateService(
          nativeService: nativeService,
          alarmRepository: alarmRepo,
          historyRepository: historyRepo,
        );
        service.handleTrigger(strictAlarm.toMap());
        await service.onMissionSuccess(buildSuccessResult(MissionType.math));

        await service.finishAndDismiss();

        expect(nativeService.stopCalls, 1);
        expect(nativeService.isSoundCurrentlyPlaying, isFalse);
        expect(service.currentState.value, AlarmState.idle);
        expect(service.activeAlarm.value, isNull);
        expect(service.areMissionsCompleted.value, isFalse);
        expect(historyRepo.records.length, 1);
        expect(historyRepo.records.first.status, AlarmHistoryStatus.completed);
        expect(nativeService.scheduledIds, contains('strict_1'));
      },
    );

    testWidgets(
      '5 & 6. Mission start pauses sound; 30s inactivity resumes; Continue Mission pauses again',
      (tester) async {
        final service = AlarmStateService(
          nativeService: nativeService,
          alarmRepository: alarmRepo,
          historyRepository: historyRepo,
          inactivityTimeout: const Duration(seconds: 30),
          maxMissionDuration: const Duration(minutes: 5),
        );

        await tester.pumpWidget(buildStrictTestApp(stateService: service));
        service.handleTrigger(strictAlarm.toMap());
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(AlarmRingingScreen));
        // Start mission (don't await future because route stays open until popped)
        // ignore: unawaited_futures
        service.startMission(ctx);
        await tester.pumpAndSettle();

        expect(nativeService.pauseCalls, 1);
        expect(service.isSoundPaused.value, isTrue);
        expect(service.wasSoundResumedDueToInactivity.value, isFalse);

        // Interact at 20s -> resets 30s inactivity window
        await tester.pump(const Duration(seconds: 20));
        service.reportMissionInteraction();
        await tester.pump(const Duration(seconds: 20));

        // 40s total, only 20s since last interaction -> still paused
        expect(service.isSoundPaused.value, isTrue);
        expect(service.wasSoundResumedDueToInactivity.value, isFalse);

        // Advance another 11s (31s since last interaction) -> ringtone resumes!
        await tester.pump(const Duration(seconds: 11));
        expect(service.isSoundPaused.value, isFalse);
        expect(service.wasSoundResumedDueToInactivity.value, isTrue);
        expect(nativeService.resumeCalls, 1);
        expect(find.text('Continue Mission'), findsOneWidget);

        // Explicit Continue Mission pauses sound again & starts fresh 30s window
        await tester.tap(find.text('Continue Mission'));
        await tester.pumpAndSettle();

        expect(nativeService.pauseCalls, 2);
        expect(service.isSoundPaused.value, isTrue);
        expect(service.wasSoundResumedDueToInactivity.value, isFalse);

        // Clean up active mission route before test ends
        Get.back(result: buildSuccessResult(MissionType.math));
        await tester.pumpAndSettle();
        await service.finishAndDismiss();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '7. 5-minute cumulative max mission duration overrides interactions & locks Continue Mission',
      (tester) async {
        final service = AlarmStateService(
          nativeService: nativeService,
          alarmRepository: alarmRepo,
          historyRepository: historyRepo,
          inactivityTimeout: const Duration(seconds: 30),
          maxMissionDuration: const Duration(minutes: 5),
        );

        await tester.pumpWidget(buildStrictTestApp(stateService: service));
        service.handleTrigger(strictAlarm.toMap());
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(AlarmRingingScreen));
        // ignore: unawaited_futures
        service.startMission(ctx);
        await tester.pumpAndSettle();

        // Keep interacting every 20s across 5 minutes -> inactivity never fires,
        // yet 5-minute cumulative max limit MUST fire!
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 20));
          service.reportMissionInteraction();
        }
        await tester.pump();

        expect(service.wasSoundResumedDueToMaxDuration.value, isTrue);
        expect(service.isSoundPaused.value, isFalse);
        expect(nativeService.resumeCalls, 1);
        expect(
          find.textContaining('Maximum mission duration reached'),
          findsOneWidget,
        );

        // Calling continueMission or reportMissionInteraction must NOT re-pause sound
        final pauseCountBefore = nativeService.pauseCalls;
        service.reportMissionInteraction();
        await service.continueMission();
        expect(nativeService.pauseCalls, pauseCountBefore);
        expect(service.isSoundPaused.value, isFalse);

        Get.back(result: buildSuccessResult(MissionType.math));
        await tester.pumpAndSettle();
        await service.finishAndDismiss();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '8. Controlled return to alarm resumes ringtone & preserves session + cumulative limit',
      (tester) async {
        final service = AlarmStateService(
          nativeService: nativeService,
          alarmRepository: alarmRepo,
          historyRepository: historyRepo,
          inactivityTimeout: const Duration(seconds: 30),
          maxMissionDuration: const Duration(seconds: 40),
          nowProvider: () => tester.binding.clock.now(),
        );

        await tester.pumpWidget(buildStrictTestApp(stateService: service));
        service.handleTrigger(strictAlarm.toMap());
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(AlarmRingingScreen));
        // ignore: unawaited_futures
        service.startMission(ctx);
        await tester.pumpAndSettle();

        // Spend 25s in mission, then perform controlled return to alarm screen
        await tester.pump(const Duration(seconds: 25));
        Get.back();
        await tester.pumpAndSettle();

        expect(Get.currentRoute, AppRoutes.alarmRinging);
        expect(service.currentState.value, AlarmState.ringing);
        expect(service.activeAlarm.value?.id, 'strict_1');
        expect(service.isSoundPaused.value, isFalse);
        expect(nativeService.resumeCalls, 1);

        // Wait 30s on alarm screen -> must NOT count toward cumulative mission time
        await tester.pump(const Duration(seconds: 30));
        expect(service.wasSoundResumedDueToMaxDuration.value, isFalse);

        // Re-enter mission -> only ~15s remains of 40s cumulative budget
        final ctx2 = tester.element(find.byType(AlarmRingingScreen));
        // ignore: unawaited_futures
        service.startMission(ctx2);
        await tester.pumpAndSettle();
        expect(service.isSoundPaused.value, isTrue);

        await tester.pump(const Duration(seconds: 16));
        expect(service.wasSoundResumedDueToMaxDuration.value, isTrue);
        expect(service.isSoundPaused.value, isFalse);

        Get.back(result: buildSuccessResult(MissionType.math));
        await tester.pumpAndSettle();
        await service.finishAndDismiss();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '9. Active Alarm UI has no Snooze button & gates Dismiss until mission completes',
      (tester) async {
        final service = AlarmStateService(
          nativeService: nativeService,
          alarmRepository: alarmRepo,
          historyRepository: historyRepo,
        );

        await tester.pumpWidget(buildStrictTestApp(stateService: service));
        service.handleTrigger(strictAlarm.toMap());
        await tester.pumpAndSettle();

        expect(find.text('Snooze'), findsNothing);
        expect(find.text('Start Mission'), findsOneWidget);
        expect(find.text('Dismiss Alarm'), findsNothing);

        // Complete mission -> Dismiss Alarm appears
        await service.onMissionSuccess(buildSuccessResult(MissionType.math));
        await tester.pumpAndSettle();

        expect(find.text('Dismiss Alarm'), findsOneWidget);
        await tester.tap(find.text('Dismiss Alarm'));
        await tester.pumpAndSettle();

        expect(nativeService.stopCalls, 1);
        expect(Get.currentRoute, AppRoutes.home);
      },
    );

    test('AppSettings volume serialization handles bounds and defaults', () {
      const custom = AppSettings(alarmVolume: 95);
      final roundTrip = AppSettings.fromMap(custom.toMap());
      expect(roundTrip.alarmVolume, 95);
      expect(AppSettings.defaults.alarmVolume, 80);
    });
  });
}
