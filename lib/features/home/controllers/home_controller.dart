import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';

class NextAlarmInfo {
  const NextAlarmInfo({required this.alarm, required this.occursAt});

  final AlarmModel alarm;
  final DateTime occursAt;
}

class HomeController extends GetxController with WidgetsBindingObserver {
  HomeController(this._repository);

  final AlarmRepository _repository;

  final RxList<AlarmModel> _alarms = <AlarmModel>[].obs;
  final Rx<DateTime> _now = DateTime.now().obs;
  Timer? _clockTimer;

  List<AlarmModel> get alarms => _alarms;

  DateTime get now => _now.value;

  NextAlarmInfo? get nextAlarm {
    NextAlarmInfo? result;

    for (final alarm in _alarms) {
      final occurrence = AppDateUtils.nextOccurrence(alarm, now);
      if (occurrence == null) {
        continue;
      }
      if (result == null || occurrence.isBefore(result.occursAt)) {
        result = NextAlarmInfo(alarm: alarm, occursAt: occurrence);
      }
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    reloadAlarms();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _now.value = DateTime.now();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _now.value = DateTime.now();
      reloadAlarms();
    }
  }

  void reloadAlarms() {
    _alarms.assignAll(_repository.getAlarms());
  }

  Future<bool> setAlarmEnabled(String alarmId, bool enabled) async {
    final saved = await _repository.setEnabled(alarmId, enabled);
    if (!saved) {
      return false;
    }

    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index != -1) {
      final updated = _alarms[index].copyWith(enabled: enabled);
      _alarms[index] = updated;
      if (Get.isRegistered<AlarmNativeService>()) {
        final native = Get.find<AlarmNativeService>();
        if (enabled) {
          final scheduled = await native.scheduleAlarm(updated);
          if (!scheduled) {
            await _repository.setEnabled(alarmId, false);
            _alarms[index] = _alarms[index].copyWith(enabled: false);
            return false;
          }
        } else {
          await native.cancelAlarm(alarmId);
        }
      }
    }
    return true;
  }

  Future<bool> deleteAlarm(String alarmId) async {
    final deleted = await _repository.deleteAlarm(alarmId);
    if (deleted) {
      _alarms.removeWhere((alarm) => alarm.id == alarmId);
      if (Get.isRegistered<AlarmNativeService>()) {
        await Get.find<AlarmNativeService>().cancelAlarm(alarmId);
      }
    }
    return deleted;
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
