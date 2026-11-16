import 'dart:convert';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';

class BackupImportResult {
  const BackupImportResult({
    required this.success,
    this.alarmsImported = 0,
    this.historyImported = 0,
    this.settingsImported = false,
    this.errorMessage,
  });

  final bool success;
  final int alarmsImported;
  final int historyImported;
  final bool settingsImported;
  final String? errorMessage;
}

class BackupService {
  BackupService({
    required this.alarmRepository,
    required this.historyRepository,
    required this.settingsRepository,
  });

  final AlarmRepository alarmRepository;
  final AlarmHistoryRepository historyRepository;
  final SettingsRepository settingsRepository;

  static const int currentSchemaVersion = 1;

  Future<String> exportBackupJson() async {
    final alarms = alarmRepository.getAlarms();
    final history = historyRepository.getAll();
    final settings = settingsRepository.load();

    final payload = <String, dynamic>{
      'schemaVersion': currentSchemaVersion,
      'appName': AppConstants.appName,
      'appVersion': AppConstants.appVersion,
      'exportedAt': DateTime.now().millisecondsSinceEpoch,
      'settings': settings.toMap(),
      'alarms': alarms.map((a) => a.toMap()).toList(growable: false),
      'history': history.map((h) => h.toMap()).toList(growable: false),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<BackupImportResult> importBackupJson(String jsonString) async {
    if (jsonString.trim().isEmpty) {
      return const BackupImportResult(
        success: false,
        errorMessage: 'Backup content is empty.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (_) {
      return const BackupImportResult(
        success: false,
        errorMessage: 'Invalid JSON format. Please check the backup text.',
      );
    }

    if (decoded is! Map) {
      return const BackupImportResult(
        success: false,
        errorMessage: 'Invalid backup structure.',
      );
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! num || schemaVersion.toInt() < 1) {
      return const BackupImportResult(
        success: false,
        errorMessage: 'Unsupported backup schema version.',
      );
    }

    final hasAnySection =
        decoded.containsKey('settings') ||
        decoded.containsKey('alarms') ||
        decoded.containsKey('history');
    if (!hasAnySection) {
      return const BackupImportResult(
        success: false,
        errorMessage: 'Backup contains no alarms, history, or settings data.',
      );
    }

    int alarmsCount = 0;
    int historyCount = 0;
    bool settingsSaved = false;
    int skippedInvalid = 0;

    // 1. Restore Settings
    final rawSettings = decoded['settings'];
    if (rawSettings is Map) {
      try {
        final settings = AppSettings.fromMap(rawSettings);
        final saved = await settingsRepository.save(settings);
        if (saved) {
          settingsSaved = true;
        }
      } catch (_) {
        skippedInvalid++;
      }
    } else if (rawSettings != null) {
      skippedInvalid++;
    }

    // 2. Restore Alarms safely (deduplicating repeated IDs in backup)
    final rawAlarms = decoded['alarms'];
    if (rawAlarms is List) {
      final seenAlarmIds = <String>{};
      for (final item in rawAlarms) {
        if (item is Map) {
          try {
            final alarm = AlarmModel.fromMap(item);
            if (seenAlarmIds.add(alarm.id)) {
              final saved = await alarmRepository.saveAlarm(alarm);
              if (saved) {
                alarmsCount++;
              }
            }
          } catch (_) {
            skippedInvalid++;
          }
        } else {
          skippedInvalid++;
        }
      }
    } else if (rawAlarms != null) {
      skippedInvalid++;
    }

    // 3. Restore History safely (deduplicating repeated IDs in backup)
    final rawHistory = decoded['history'];
    if (rawHistory is List) {
      final seenHistoryIds = <String>{};
      for (final item in rawHistory) {
        if (item is Map) {
          try {
            final record = AlarmHistoryRecord.fromMap(item);
            if (seenHistoryIds.add(record.id)) {
              final saved = await historyRepository.addRecord(record);
              if (saved) {
                historyCount++;
              }
            }
          } catch (_) {
            skippedInvalid++;
          }
        } else {
          skippedInvalid++;
        }
      }
    } else if (rawHistory != null) {
      skippedInvalid++;
    }

    if (!settingsSaved &&
        alarmsCount == 0 &&
        historyCount == 0 &&
        skippedInvalid > 0) {
      return const BackupImportResult(
        success: false,
        errorMessage: 'Backup file contained only invalid or unreadable data.',
      );
    }

    return BackupImportResult(
      success: true,
      alarmsImported: alarmsCount,
      historyImported: historyCount,
      settingsImported: settingsSaved,
    );
  }
}
