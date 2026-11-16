import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/providers/alarm_history_local_provider.dart';
import 'package:smart_alarm/data/providers/alarm_local_provider.dart';
import 'package:smart_alarm/data/providers/settings_local_provider.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';
import 'package:smart_alarm/features/alarm/controllers/create_alarm_controller.dart';
import 'package:smart_alarm/features/home/controllers/home_controller.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';

class _InMemoryLocalStorage implements LocalStorageService {
  final Map<String, dynamic> _data = <String, dynamic>{};

  @override
  T? read<T>(String key) {
    final value = _data[key];
    return value is T ? value : null;
  }

  @override
  Map<String, dynamic>? readMap(String key) {
    final value = _data[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> write(String key, dynamic value) async {
    _data[key] = value;
  }
}

class _ConfigurableNativeService extends AlarmNativeService {
  bool shouldSucceedScheduling = true;
  final List<String> scheduled = <String>[];
  final List<String> cancelled = <String>[];

  @override
  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    if (!shouldSucceedScheduling) return false;
    scheduled.add(alarm.id);
    return true;
  }

  @override
  Future<bool> cancelAlarm(String id) async {
    cancelled.add(id);
    return true;
  }
}

void main() {
  late _InMemoryLocalStorage storage;
  late AlarmRepository alarmRepository;
  late AlarmHistoryRepository historyRepository;
  late SettingsController settingsController;
  late _ConfigurableNativeService nativeService;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storage = _InMemoryLocalStorage();
    alarmRepository = AlarmRepository(AlarmLocalProvider(storage));
    historyRepository = AlarmHistoryRepository(
      AlarmHistoryLocalProvider(storage),
    );
    final settingsRepo = SettingsRepository(SettingsLocalProvider(storage));
    settingsController = Get.put(SettingsController(settingsRepo));
    nativeService = Get.put<_ConfigurableNativeService>(
      _ConfigurableNativeService(),
    );
    Get.put<AlarmNativeService>(nativeService);
  });

  tearDown(() {
    Get.reset();
  });

  group('Repositories & Corrupted Local Data Resilience', () {
    test('AlarmLocalProvider skips non-map corrupted entries safely', () async {
      await storage.write('alarms_v1', <dynamic>[
        'corrupted-string-entry',
        42,
        AlarmModel(
          id: 'valid_1',
          hour: 6,
          minute: 30,
          label: 'Valid Alarm',
          repeatDays: const <int>[1, 3],
          soundId: 'default',
          vibrationEnabled: true,
          snoozeEnabled: false,
          snoozeMinutes: 5,
          enabled: true,
          createdAt: DateTime(2026, 11, 12, 6, 0),
        ).toMap(),
      ]);

      final loaded = alarmRepository.getAlarms();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'valid_1');
    });

    test(
      'AlarmRepository handles duplicate IDs cleanly on save and sort',
      () async {
        final a1 = AlarmModel(
          id: 'same_id',
          hour: 8,
          minute: 15,
          label: 'First',
          repeatDays: const <int>[],
          soundId: 'default',
          vibrationEnabled: true,
          snoozeEnabled: false,
          snoozeMinutes: 5,
          enabled: true,
          createdAt: DateTime(2026, 11, 12, 6, 0),
        );
        final a2 = a1.copyWith(hour: 7, minute: 0, label: 'Updated');

        await alarmRepository.saveAlarm(a1);
        await alarmRepository.saveAlarm(a2);

        final alarms = alarmRepository.getAlarms();
        expect(alarms.length, 1);
        expect(alarms.first.label, 'Updated');
        expect(alarms.first.hour, 7);
      },
    );

    test(
      'AlarmHistoryRepository deduplicates by ID and filters accurately',
      () async {
        final baseTime = DateTime(2026, 11, 12, 7, 0);
        final r1 = AlarmHistoryRecord(
          id: 'h1',
          alarmId: 'a1',
          alarmLabel: 'Wake',
          scheduledTime: baseTime,
          actualTime: baseTime,
          status: AlarmHistoryStatus.completed,
        );
        final r2 = AlarmHistoryRecord(
          id: 'h2',
          alarmId: 'a1',
          alarmLabel: 'Missed',
          scheduledTime: baseTime.subtract(const Duration(days: 5)),
          actualTime: baseTime.subtract(const Duration(days: 5)),
          status: AlarmHistoryStatus.missed,
        );

        await historyRepository.addRecord(r1);
        await historyRepository.addRecord(r1.copyWith(durationSeconds: 45));
        await historyRepository.addRecord(r2);

        expect(historyRepository.getAll().length, 2);
        expect(historyRepository.getById('h1')?.durationSeconds, 45);
        expect(
          historyRepository
              .filter(status: AlarmHistoryStatus.completed)
              .single
              .id,
          'h1',
        );
      },
    );
  });

  group('CreateAlarmController & HomeController Scheduling Guard', () {
    test('creates and edits alarm while syncing native scheduler', () async {
      final createController = CreateAlarmController(
        alarmRepository,
        settingsController: settingsController,
      );
      createController.setTime(const TimeOfDay(hour: 6, minute: 15));
      createController.labelController.text = 'Morning Gym';
      createController.toggleDay(1);
      createController.toggleDay(4);
      createController.setMission(
        const MissionConfig(
          type: MissionType.puzzle,
          difficulty: MissionDifficulty.hard,
        ),
      );

      final created = await createController.save();
      expect(created, isTrue);
      expect(createController.scheduleWarning.value, isNull);
      expect(alarmRepository.getAlarms().length, 1);
      final saved = alarmRepository.getAlarms().single;
      expect(saved.label, 'Morning Gym');
      expect(saved.repeatDays, <int>[1, 4]);
      expect(saved.mission?.type, MissionType.puzzle);
      expect(nativeService.scheduled, contains(saved.id));

      // Edit existing alarm
      final editController = CreateAlarmController(
        alarmRepository,
        settingsController: settingsController,
        alarm: saved,
      );
      expect(editController.isEditing, isTrue);
      editController.labelController.text = 'Updated Gym';
      expect(await editController.save(), isTrue);
      expect(alarmRepository.getAlarms().single.label, 'Updated Gym');

      createController.onClose();
      editController.onClose();
    });

    test(
      'CreateAlarmController sets scheduleWarning when native schedule fails',
      () async {
        nativeService.shouldSucceedScheduling = false;

        final controller = CreateAlarmController(
          alarmRepository,
          settingsController: settingsController,
        );
        final saved = await controller.save();

        expect(saved, isTrue);
        expect(controller.scheduleWarning.value, isNotNull);
        controller.onClose();
      },
    );

    test(
      'HomeController reverts enabled toggle when native schedule fails',
      () async {
        final alarm = AlarmModel(
          id: 'toggle_test',
          hour: 7,
          minute: 0,
          label: 'Work',
          repeatDays: const <int>[],
          soundId: 'default',
          vibrationEnabled: true,
          snoozeEnabled: false,
          snoozeMinutes: 5,
          enabled: false,
          createdAt: DateTime(2026, 11, 12, 6, 0),
        );
        await alarmRepository.saveAlarm(alarm);

        final homeController = HomeController(alarmRepository);
        homeController.onInit();

        nativeService.shouldSucceedScheduling = false;
        final toggled = await homeController.setAlarmEnabled(
          'toggle_test',
          true,
        );

        expect(toggled, isFalse);
        expect(homeController.alarms.single.enabled, isFalse);
        expect(alarmRepository.getAlarms().single.enabled, isFalse);

        // Succeeds when permission is available
        nativeService.shouldSucceedScheduling = true;
        expect(
          await homeController.setAlarmEnabled('toggle_test', true),
          isTrue,
        );
        expect(homeController.alarms.single.enabled, isTrue);

        // Delete cancels alarm natively
        expect(await homeController.deleteAlarm('toggle_test'), isTrue);
        expect(nativeService.cancelled, contains('toggle_test'));
        expect(homeController.alarms, isEmpty);

        homeController.onClose();
      },
    );
  });
}
