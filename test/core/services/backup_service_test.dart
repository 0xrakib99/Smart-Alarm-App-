import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/core/services/backup_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';

class FakeAlarmRepo implements AlarmRepository {
  final List<AlarmModel> alarms = <AlarmModel>[];

  @override
  List<AlarmModel> getAlarms() => List<AlarmModel>.from(alarms);

  @override
  Future<bool> saveAlarm(AlarmModel alarm) async {
    final idx = alarms.indexWhere((a) => a.id == alarm.id);
    if (idx != -1) {
      alarms[idx] = alarm;
    } else {
      alarms.add(alarm);
    }
    return true;
  }

  @override
  Future<bool> deleteAlarm(String id) async {
    alarms.removeWhere((a) => a.id == id);
    return true;
  }

  @override
  Future<bool> setEnabled(String id, bool enabled) async => true;
}

class FakeHistoryRepo implements AlarmHistoryRepository {
  final List<AlarmHistoryRecord> history = <AlarmHistoryRecord>[];

  @override
  List<AlarmHistoryRecord> getAll({bool newestFirst = true}) =>
      List<AlarmHistoryRecord>.from(history);

  @override
  AlarmHistoryRecord? getById(String id) => history
      .cast<AlarmHistoryRecord?>()
      .firstWhere((h) => h?.id == id, orElse: () => null);

  @override
  Future<bool> addRecord(AlarmHistoryRecord record) async {
    history.add(record);
    return true;
  }

  @override
  Future<bool> deleteRecord(String id) async {
    history.removeWhere((h) => h.id == id);
    return true;
  }

  @override
  Future<bool> clearHistory() async {
    history.clear();
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

class FakeSettingsRepo implements SettingsRepository {
  AppSettings current = AppSettings.defaults;

  @override
  AppSettings load() => current;

  @override
  Future<bool> save(AppSettings settings) async {
    current = settings;
    return true;
  }
}

void main() {
  group('BackupService', () {
    late FakeAlarmRepo alarmRepo;
    late FakeHistoryRepo historyRepo;
    late FakeSettingsRepo settingsRepo;
    late BackupService backupService;

    setUp(() {
      alarmRepo = FakeAlarmRepo();
      historyRepo = FakeHistoryRepo();
      settingsRepo = FakeSettingsRepo();
      backupService = BackupService(
        alarmRepository: alarmRepo,
        historyRepository: historyRepo,
        settingsRepository: settingsRepo,
      );
    });

    test('exportBackupJson creates valid JSON with schema metadata', () async {
      await alarmRepo.saveAlarm(
        AlarmModel(
          id: 'test_1',
          hour: 8,
          minute: 0,
          label: 'Test Alarm',
          repeatDays: const <int>[1, 2],
          soundId: 'default',
          vibrationEnabled: true,
          snoozeEnabled: true,
          snoozeMinutes: 5,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      await historyRepo.addRecord(
        AlarmHistoryRecord(
          id: 'hist_1',
          alarmId: 'test_1',
          alarmLabel: 'Test Alarm',
          scheduledTime: DateTime.now(),
          actualTime: DateTime.now(),
          status: AlarmHistoryStatus.completed,
        ),
      );

      final jsonStr = await backupService.exportBackupJson();
      expect(jsonStr, isNotEmpty);

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['schemaVersion'], 1);
      expect(decoded['appName'], 'Smart Alarm');
      expect((decoded['alarms'] as List).length, 1);
      expect((decoded['history'] as List).length, 1);
      expect(decoded['settings'], isNotNull);
    });

    test('importBackupJson imports valid backup payload', () async {
      final payload = {
        'schemaVersion': 1,
        'appName': 'Smart Alarm',
        'exportedAt': DateTime.now().millisecondsSinceEpoch,
        'settings': {
          'themePreference': 'dark',
          'alarmSoundId': 'chime',
          'vibrationEnabled': true,
          'snoozeEnabled': true,
          'snoozeMinutes': 10,
        },
        'alarms': [
          {
            'id': 'imported_1',
            'hour': 6,
            'minute:': 45,
            'label': 'Imported',
            'repeatDays': [1, 2, 3],
            'soundId': 'chime',
            'vibrationEnabled': true,
            'snoozeEnabled': true,
            'snoozeMinutes': 10,
            'enabled': true,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          },
        ],
        'history': [
          {
            'id': 'hist_imported_1',
            'alarmId': 'imported_1',
            'alarmLabel': 'Imported',
            'scheduledTime': DateTime.now().millisecondsSinceEpoch,
            'actualTime': DateTime.now().millisecondsSinceEpoch,
            'status': 'completed',
            'durationSeconds': 15,
            'snoozeCount': 0,
          },
        ],
      };

      final jsonStr = jsonEncode(payload);
      final result = await backupService.importBackupJson(jsonStr);

      expect(result.success, isTrue);
      expect(result.alarmsImported, 1);
      expect(result.historyImported, 1);
      expect(result.settingsImported, isTrue);
      expect(alarmRepo.alarms.length, 1);
      expect(historyRepo.history.length, 1);
      expect(settingsRepo.current.themePreference, ThemePreference.dark);
    });

    test('importBackupJson safely rejects invalid or malformed JSON', () async {
      final result = await backupService.importBackupJson('{invalid_json}');
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Invalid JSON'));
    });

    test('importBackupJson rejects unsupported schema', () async {
      final jsonStr = jsonEncode({'schemaVersion': 0});
      final result = await backupService.importBackupJson(jsonStr);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Unsupported backup schema'));
    });

    test(
      'importBackupJson rejects backup with no recognized sections',
      () async {
        final jsonStr = jsonEncode({
          'schemaVersion': 1,
          'appName': 'Smart Alarm',
        });
        final result = await backupService.importBackupJson(jsonStr);
        expect(result.success, isFalse);
        expect(
          result.errorMessage,
          contains('no alarms, history, or settings'),
        );
      },
    );

    test(
      'importBackupJson deduplicates duplicate alarm and history IDs',
      () async {
        final nowMs = DateTime(2026, 11, 12, 7, 0).millisecondsSinceEpoch;
        final jsonStr = jsonEncode({
          'schemaVersion': 1,
          'alarms': [
            {
              'id': 'dup_alarm',
              'hour': 6,
              'minute': 30,
              'label': 'First',
              'repeatDays': [1],
              'soundId': 'default',
              'vibrationEnabled': true,
              'snoozeEnabled': false,
              'snoozeMinutes': 5,
              'enabled': true,
              'createdAt': nowMs,
            },
            {
              'id': 'dup_alarm',
              'hour': 7,
              'minute': 30,
              'label': 'Second Duplicate',
              'repeatDays': [2],
              'soundId': 'default',
              'vibrationEnabled': true,
              'snoozeEnabled': false,
              'snoozeMinutes': 5,
              'enabled': true,
              'createdAt': nowMs,
            },
          ],
          'history': [
            {
              'id': 'dup_hist',
              'alarmId': 'dup_alarm',
              'alarmLabel': 'First',
              'scheduledTime': nowMs,
              'actualTime': nowMs,
              'status': 'completed',
            },
            {
              'id': 'dup_hist',
              'alarmId': 'dup_alarm',
              'alarmLabel': 'Duplicate',
              'scheduledTime': nowMs,
              'actualTime': nowMs,
              'status': 'completed',
            },
          ],
        });

        final result = await backupService.importBackupJson(jsonStr);
        expect(result.success, isTrue);
        expect(result.alarmsImported, 1);
        expect(result.historyImported, 1);
        expect(alarmRepo.alarms.single.label, 'First');
        expect(historyRepo.history.single.alarmLabel, 'First');
      },
    );

    test(
      'importBackupJson rejects completely unreadable data sections',
      () async {
        final jsonStr = jsonEncode({
          'schemaVersion': 1,
          'settings': 'not-a-map',
          'alarms': 'not-a-list',
          'history': ['not-a-map'],
        });
        final result = await backupService.importBackupJson(jsonStr);
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('invalid or unreadable'));
      },
    );
  });
}
