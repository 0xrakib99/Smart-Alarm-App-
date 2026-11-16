import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  final Rx<AppSettings> _settings = AppSettings.defaults.obs;

  AppSettings get settings => _settings.value;

  ThemeMode get themeMode {
    return switch (settings.themePreference) {
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
      ThemePreference.system => ThemeMode.system,
    };
  }

  @override
  void onInit() {
    super.onInit();
    _settings.value = _repository.load();
  }

  Future<bool> setThemePreference(ThemePreference preference) {
    return _update(settings.copyWith(themePreference: preference));
  }

  Future<bool> setDefaultAlarmSound(String soundId) {
    return _update(settings.copyWith(alarmSoundId: soundId));
  }

  Future<bool> setVibrationEnabled(bool enabled) {
    return _update(settings.copyWith(vibrationEnabled: enabled));
  }

  Future<bool> setSnoozeEnabled(bool enabled) {
    return _update(settings.copyWith(snoozeEnabled: enabled));
  }

  Future<bool> setSnoozeMinutes(int minutes) {
    return _update(settings.copyWith(snoozeMinutes: minutes));
  }

  Future<bool> setMaxSnoozeCount(int count) {
    return _update(settings.copyWith(maxSnoozeCount: count));
  }

  Future<bool> setDefaultDifficulty(MissionDifficulty difficulty) {
    return _update(settings.copyWith(defaultDifficulty: difficulty));
  }

  Future<bool> setAlarmVolume(int volume) {
    return _update(settings.copyWith(alarmVolume: volume));
  }

  Future<bool> _update(AppSettings nextSettings) async {
    final previousSettings = _settings.value;
    _settings.value = nextSettings;
    update();

    final saved = await _repository.save(nextSettings);
    if (!saved) {
      _settings.value = previousSettings;
      update();
    }
    return saved;
  }
}
