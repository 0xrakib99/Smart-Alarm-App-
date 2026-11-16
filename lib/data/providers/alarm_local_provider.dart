import 'dart:developer' as developer;
import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';

class AlarmLocalProvider {
  AlarmLocalProvider(this._storage);

  final LocalStorageService _storage;

  static const String _alarmsKey = 'alarms_v1';

  List<AlarmModel> readAll() {
    final rawAlarms = _storage.read<List<dynamic>>(_alarmsKey);
    if (rawAlarms == null) {
      return <AlarmModel>[];
    }

    final alarms = <AlarmModel>[];
    for (final item in rawAlarms) {
      if (item is Map) {
        try {
          alarms.add(AlarmModel.fromMap(item));
        } catch (e) {
          developer.log(
            'Skipped malformed stored alarm record: $e',
            name: 'AlarmLocalProvider',
          );
        }
      }
    }
    return alarms;
  }

  Future<void> writeAll(List<AlarmModel> alarms) {
    return _storage.write(
      _alarmsKey,
      alarms.map((alarm) => alarm.toMap()).toList(growable: false),
    );
  }
}
