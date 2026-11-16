import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/providers/alarm_local_provider.dart';

class AlarmRepository {
  AlarmRepository(this._localProvider);

  final AlarmLocalProvider _localProvider;

  List<AlarmModel> getAlarms() {
    try {
      final alarms = _localProvider.readAll();
      alarms.sort(_byTime);
      return alarms;
    } catch (_) {
      return <AlarmModel>[];
    }
  }

  Future<bool> saveAlarm(AlarmModel alarm) async {
    try {
      final alarms = _localProvider.readAll();
      final index = alarms.indexWhere((item) => item.id == alarm.id);
      if (index == -1) {
        alarms.add(alarm);
      } else {
        alarms[index] = alarm;
      }
      alarms.sort(_byTime);
      await _localProvider.writeAll(alarms);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAlarm(String id) async {
    try {
      final alarms = _localProvider.readAll();
      final index = alarms.indexWhere((alarm) => alarm.id == id);
      if (index == -1) {
        return false;
      }
      alarms.removeAt(index);
      await _localProvider.writeAll(alarms);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setEnabled(String id, bool enabled) async {
    try {
      final alarms = _localProvider.readAll();
      final index = alarms.indexWhere((alarm) => alarm.id == id);
      if (index == -1) {
        return false;
      }
      alarms[index] = alarms[index].copyWith(enabled: enabled);
      await _localProvider.writeAll(alarms);
      return true;
    } catch (_) {
      return false;
    }
  }

  static int _byTime(AlarmModel a, AlarmModel b) {
    final hourComparison = a.hour.compareTo(b.hour);
    if (hourComparison != 0) {
      return hourComparison;
    }
    final minuteComparison = a.minute.compareTo(b.minute);
    if (minuteComparison != 0) {
      return minuteComparison;
    }
    return a.createdAt.compareTo(b.createdAt);
  }
}
