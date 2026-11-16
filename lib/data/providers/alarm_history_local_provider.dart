import 'dart:developer' as developer;
import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';

class AlarmHistoryLocalProvider {
  AlarmHistoryLocalProvider(this._storage);

  final LocalStorageService _storage;

  static const String _historyKey = 'alarm_history_v1';

  List<AlarmHistoryRecord> readAll() {
    final rawHistory = _storage.read<List<dynamic>>(_historyKey);
    if (rawHistory == null) {
      return <AlarmHistoryRecord>[];
    }

    final records = <AlarmHistoryRecord>[];
    for (final item in rawHistory) {
      if (item is Map) {
        try {
          records.add(AlarmHistoryRecord.fromMap(item));
        } catch (e) {
          developer.log(
            'Skipped malformed stored history record: $e',
            name: 'AlarmHistoryLocalProvider',
          );
        }
      }
    }
    return records;
  }

  Future<void> writeAll(List<AlarmHistoryRecord> records) {
    return _storage.write(
      _historyKey,
      records.map((r) => r.toMap()).toList(growable: false),
    );
  }

  Future<void> clear() {
    return _storage.remove(_historyKey);
  }
}
