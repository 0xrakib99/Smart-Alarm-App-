import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/constants/app_sounds.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';

class CreateAlarmController extends GetxController {
  CreateAlarmController(
    this._repository, {
    required SettingsController settingsController,
    AlarmModel? alarm,
  }) : _editingAlarm = alarm,
       repeatDays = (<int>{...?alarm?.repeatDays}).obs,
       soundId =
           (alarm?.soundId ?? settingsController.settings.alarmSoundId).obs,
       vibrationEnabled =
           (alarm?.vibrationEnabled ??
                   settingsController.settings.vibrationEnabled)
               .obs,
       snoozeEnabled =
           (alarm?.snoozeEnabled ?? settingsController.settings.snoozeEnabled)
               .obs,
       snoozeMinutes =
           (alarm?.snoozeMinutes ?? settingsController.settings.snoozeMinutes)
               .obs {
    final suggestedTime = DateTime.now().add(const Duration(minutes: 5));
    time = TimeOfDay(
      hour: alarm?.hour ?? suggestedTime.hour,
      minute: alarm?.minute ?? suggestedTime.minute,
    ).obs;
    if (alarm != null && alarm.missions.isNotEmpty) {
      missions.assignAll(alarm.missions);
    } else if (alarm?.mission != null) {
      missions.assignAll([alarm!.mission!]);
    }
    customSoundPath.value = alarm?.customSoundPath;
    customSoundName.value = alarm?.customSoundName;
    labelController = TextEditingController(text: alarm?.label ?? '');
  }

  final AlarmRepository _repository;
  final AlarmModel? _editingAlarm;

  late final Rx<TimeOfDay> time;
  late final TextEditingController labelController;
  final RxSet<int> repeatDays;
  final RxString soundId;
  final RxnString customSoundPath = RxnString();
  final RxnString customSoundName = RxnString();
  final RxBool vibrationEnabled;
  final RxBool snoozeEnabled;
  final RxInt snoozeMinutes;
  final RxList<MissionConfig> missions = <MissionConfig>[].obs;
  final RxBool isSaving = false.obs;
  final RxnString scheduleWarning = RxnString();

  MissionConfig? get mission => missions.isNotEmpty ? missions.first : null;

  bool get isEditing => _editingAlarm != null;

  bool get isCustomSound =>
      soundId.value == 'custom' && customSoundPath.value != null;

  Set<int> get selectedDays => repeatDays.toSet();

  String get soundName {
    if (soundId.value == 'custom' &&
        customSoundName.value != null &&
        customSoundName.value!.isNotEmpty) {
      return customSoundName.value!;
    }
    return AppSounds.nameFor(soundId.value);
  }

  void setTime(TimeOfDay value) {
    time.value = value;
  }

  void toggleDay(int day) {
    if (repeatDays.contains(day)) {
      repeatDays.remove(day);
    } else {
      repeatDays.add(day);
    }
  }

  void setSound(String id) {
    soundId.value = id;
    customSoundPath.value = null;
    customSoundName.value = null;
  }

  void setSoundSelection({
    required String id,
    String? customPath,
    String? customName,
  }) {
    soundId.value = id;
    customSoundPath.value = customPath;
    customSoundName.value = customName;
  }

  void setVibrationEnabled(bool enabled) {
    vibrationEnabled.value = enabled;
  }

  void setSnoozeEnabled(bool enabled) {
    snoozeEnabled.value = enabled;
  }

  void setMission(MissionConfig value) {
    missions.assignAll([value]);
  }

  void setMissions(List<MissionConfig> values) {
    missions.assignAll(values);
  }

  void clearMissions() {
    missions.clear();
  }

  Future<bool> save() async {
    if (isSaving.value) {
      return false;
    }

    isSaving.value = true;
    scheduleWarning.value = null;
    try {
      final trimmedLabel = labelController.text.trim();
      final sortedDays = repeatDays.toList()..sort();
      final alarm = AlarmModel(
        id: _editingAlarm?.id ?? AlarmModel.generateId(),
        hour: time.value.hour,
        minute: time.value.minute,
        label: trimmedLabel.isEmpty
            ? AppConstants.defaultAlarmLabel
            : trimmedLabel,
        repeatDays: sortedDays,
        soundId: soundId.value,
        customSoundPath: customSoundPath.value,
        customSoundName: customSoundName.value,
        vibrationEnabled: vibrationEnabled.value,
        snoozeEnabled: snoozeEnabled.value,
        snoozeMinutes: snoozeMinutes.value,
        enabled: _editingAlarm?.enabled ?? true,
        createdAt: _editingAlarm?.createdAt ?? DateTime.now(),
        missions: missions.toList(),
      );

      final saved = await _repository.saveAlarm(alarm);
      if (saved && alarm.enabled && Get.isRegistered<AlarmNativeService>()) {
        final scheduled = await Get.find<AlarmNativeService>().scheduleAlarm(
          alarm,
        );
        if (!scheduled) {
          scheduleWarning.value =
              'Alarm saved, but Android could not schedule it. Check exact alarm permissions.';
        }
      }
      return saved;
    } catch (e) {
      developer.log('Failed to save alarm: $e', name: 'CreateAlarmController');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    labelController.dispose();
    super.onClose();
  }
}
