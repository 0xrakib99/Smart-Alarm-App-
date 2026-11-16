import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/providers/alarm_history_local_provider.dart';

class AlarmHistoryRepository {
  AlarmHistoryRepository(this._localProvider);

  final AlarmHistoryLocalProvider _localProvider;

  List<AlarmHistoryRecord> getAll({bool newestFirst = true}) {
    try {
      final records = _localProvider.readAll();
      records.sort((a, b) {
        final comparison = a.actualTime.compareTo(b.actualTime);
        return newestFirst ? -comparison : comparison;
      });
      return records;
    } catch (_) {
      return <AlarmHistoryRecord>[];
    }
  }

  AlarmHistoryRecord? getById(String id) {
    try {
      final records = _localProvider.readAll();
      for (final r in records) {
        if (r.id == id) return r;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> addRecord(AlarmHistoryRecord record) async {
    try {
      final records = _localProvider.readAll();
      // Deduplicate if already exists with same ID
      final existingIndex = records.indexWhere((r) => r.id == record.id);
      if (existingIndex != -1) {
        records[existingIndex] = record;
      } else {
        records.add(record);
      }
      await _localProvider.writeAll(records);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      final records = _localProvider.readAll();
      final index = records.indexWhere((r) => r.id == id);
      if (index == -1) return false;

      records.removeAt(index);
      await _localProvider.writeAll(records);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearHistory() async {
    try {
      await _localProvider.clear();
      return true;
    } catch (_) {
      return false;
    }
  }

  List<AlarmHistoryRecord> filter({
    DateTime? from,
    DateTime? to,
    AlarmHistoryStatus? status,
    bool newestFirst = true,
  }) {
    final all = getAll(newestFirst: newestFirst);
    return all
        .where((record) {
          if (status != null && record.status != status) {
            return false;
          }
          if (from != null && record.actualTime.isBefore(from)) {
            return false;
          }
          if (to != null && record.actualTime.isAfter(to)) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }
}
