import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/models/mission_config.dart';

void main() {
  group('AlarmModel', () {
    test('normalizes repeat days and round-trips through storage', () {
      final createdAt = DateTime(2026, 11, 12, 8, 15);
      final alarm = AlarmModel(
        id: 'alarm_1',
        hour: 7,
        minute: 5,
        label: 'Morning run',
        repeatDays: const <int>[5, 1, 3, 1],
        soundId: 'chime',
        vibrationEnabled: true,
        snoozeEnabled: false,
        snoozeMinutes: 10,
        enabled: true,
        createdAt: createdAt,
        mission: const MissionConfig(
          type: MissionType.math,
          difficulty: MissionDifficulty.hard,
        ),
      );

      expect(alarm.repeatDays, <int>[1, 3, 5]);

      final restored = AlarmModel.fromMap(alarm.toMap());

      expect(restored.id, 'alarm_1');
      expect(restored.hour, 7);
      expect(restored.minute, 5);
      expect(restored.label, 'Morning run');
      expect(restored.repeatDays, <int>[1, 3, 5]);
      expect(restored.soundId, 'chime');
      expect(restored.snoozeEnabled, isFalse);
      expect(restored.snoozeMinutes, 10);
      expect(restored.createdAt, createdAt);
      expect(restored.mission, alarm.mission);
    });

    test('sanitizes incomplete or invalid stored values', () {
      final alarm = AlarmModel.fromMap(<String, dynamic>{
        'id': '',
        'hour': 99,
        'minute': -5,
        'repeatDays': <dynamic>[0, 3, 9],
        'enabled': 'not a bool',
        'snoozeMinutes': 0,
      });

      expect(alarm.id, isNotEmpty);
      expect(alarm.hour, 23);
      expect(alarm.minute, 0);
      expect(alarm.repeatDays, <int>[3]);
      expect(alarm.enabled, isTrue);
      expect(alarm.snoozeMinutes, 1);
      expect(alarm.mission, isNull);
    });
  });

  group('AppSettings', () {
    test('starts with light appearance and useful defaults', () {
      const settings = AppSettings.defaults;

      expect(settings.themePreference, ThemePreference.light);
      expect(settings.alarmSoundId, 'default');
      expect(settings.vibrationEnabled, isTrue);
      expect(settings.snoozeEnabled, isTrue);
      expect(settings.snoozeMinutes, 5);
      expect(settings.maxSnoozeCount, 3);
      expect(settings.defaultDifficulty, MissionDifficulty.easy);
      expect(settings.alarmVolume, 80);
    });

    test('round-trips all preferences', () {
      const settings = AppSettings(
        themePreference: ThemePreference.dark,
        alarmSoundId: 'beacon',
        vibrationEnabled: false,
        snoozeEnabled: false,
        snoozeMinutes: 15,
        maxSnoozeCount: 5,
        defaultDifficulty: MissionDifficulty.hard,
        alarmVolume: 95,
      );

      final restored = AppSettings.fromMap(settings.toMap());

      expect(restored.themePreference, ThemePreference.dark);
      expect(restored.alarmSoundId, 'beacon');
      expect(restored.vibrationEnabled, isFalse);
      expect(restored.snoozeEnabled, isFalse);
      expect(restored.snoozeMinutes, 15);
      expect(restored.maxSnoozeCount, 5);
      expect(restored.defaultDifficulty, MissionDifficulty.hard);
      expect(restored.alarmVolume, 95);
    });

    test('falls back to safe defaults for missing values', () {
      final restored = AppSettings.fromMap(<String, dynamic>{});

      expect(restored.themePreference, ThemePreference.light);
      expect(restored.alarmSoundId, 'default');
      expect(restored.snoozeMinutes, 5);
      expect(restored.maxSnoozeCount, 3);
      expect(restored.defaultDifficulty, MissionDifficulty.easy);
    });
  });

  group('AlarmHistoryRecord', () {
    test('round-trips complete history record through storage map', () {
      final now = DateTime(2026, 5, 10, 7, 30);
      final record = AlarmHistoryRecord(
        id: 'hist_123',
        alarmId: 'alarm_abc',
        alarmLabel: 'Work Wakeup',
        scheduledTime: now,
        actualTime: now.add(const Duration(seconds: 45)),
        status: AlarmHistoryStatus.completed,
        selectedMissions: const <String>['math'],
        completedMissions: const <String>['math'],
        durationSeconds: 45,
        snoozeCount: 1,
        difficulty: 'easy',
      );

      final map = record.toMap();
      final restored = AlarmHistoryRecord.fromMap(map);

      expect(restored.id, 'hist_123');
      expect(restored.alarmId, 'alarm_abc');
      expect(restored.alarmLabel, 'Work Wakeup');
      expect(restored.status, AlarmHistoryStatus.completed);
      expect(restored.selectedMissions, <String>['math']);
      expect(restored.completedMissions, <String>['math']);
      expect(restored.durationSeconds, 45);
      expect(restored.snoozeCount, 1);
      expect(restored.difficulty, 'easy');
    });
  });

  group('MissionConfig', () {
    test('round-trips type and difficulty', () {
      const mission = MissionConfig(
        type: MissionType.memory,
        difficulty: MissionDifficulty.medium,
      );

      final restored = MissionConfig.fromMap(mission.toMap());

      expect(restored, mission);
      expect(restored.type.label, 'Memory Match');
      expect(restored.difficulty.label, 'Medium');
    });

    test('uses a safe fallback for unknown stored values', () {
      final mission = MissionConfig.fromMap(<String, dynamic>{
        'type': 'unknown',
        'difficulty': 'impossible',
      });

      expect(mission.type, MissionType.math);
      expect(mission.difficulty, MissionDifficulty.easy);
    });
  });
}
