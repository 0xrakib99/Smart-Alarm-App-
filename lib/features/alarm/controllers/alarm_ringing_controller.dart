import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/mission_config.dart';

class AlarmRingingController extends GetxController {
  AlarmRingingController({required this.alarmStateService, AlarmModel? alarm})
    : _initialAlarm = alarm;

  final AlarmStateService alarmStateService;
  final AlarmModel? _initialAlarm;

  AlarmModel get alarm =>
      alarmStateService.activeAlarm.value ??
      _initialAlarm ??
      AlarmModel(
        id: 'fallback',
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
        label: 'Alarm',
        repeatDays: const <int>[],
        soundId: 'default',
        vibrationEnabled: true,
        snoozeEnabled: false,
        snoozeMinutes: 5,
        enabled: true,
        createdAt: DateTime.now(),
      );

  AlarmState get currentState => alarmStateService.currentState.value;

  String get timeFormatted => AppDateUtils.formatTime(alarm.hour, alarm.minute);

  String get label => alarm.label.trim().isEmpty ? 'Alarm' : alarm.label;

  MissionConfig? get mission => (currentMissionIndex < alarm.missions.length)
      ? alarm.missions[currentMissionIndex]
      : alarm.mission;

  int get currentMissionIndex => alarmStateService.currentMissionIndex.value;

  int get totalMissions => alarm.missions.length;

  bool get isSoundPaused => alarmStateService.isSoundPaused.value;

  bool get wasSoundResumedDueToInactivity =>
      alarmStateService.wasSoundResumedDueToInactivity.value;

  bool get wasSoundResumedDueToMaxDuration =>
      alarmStateService.wasSoundResumedDueToMaxDuration.value;

  bool get areMissionsCompleted => alarmStateService.areMissionsCompleted.value;

  String? get alarmError => alarmStateService.alarmError.value;

  Future<void> onStartMission(BuildContext context) async {
    await alarmStateService.startMission(context);
  }

  Future<void> onContinueMission() async {
    await alarmStateService.continueMission();
  }

  Future<void> onDismiss() async {
    await alarmStateService.finishAndDismiss();
  }
}
