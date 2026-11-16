import 'package:smart_alarm/data/models/mission_config.dart';

enum ThemePreference { light, dark, system }

class AppSettings {
  const AppSettings({
    this.themePreference = ThemePreference.light,
    this.alarmSoundId = 'default',
    this.vibrationEnabled = true,
    this.snoozeEnabled = true,
    this.snoozeMinutes = 5,
    this.maxSnoozeCount = 3,
    this.defaultDifficulty = MissionDifficulty.easy,
    this.alarmVolume = 80,
  });

  static const AppSettings defaults = AppSettings();

  final ThemePreference themePreference;
  final String alarmSoundId;
  final bool vibrationEnabled;
  final bool snoozeEnabled;
  final int snoozeMinutes;
  final int maxSnoozeCount;
  final MissionDifficulty defaultDifficulty;
  final int alarmVolume;

  AppSettings copyWith({
    ThemePreference? themePreference,
    String? alarmSoundId,
    bool? vibrationEnabled,
    bool? snoozeEnabled,
    int? snoozeMinutes,
    int? maxSnoozeCount,
    MissionDifficulty? defaultDifficulty,
    int? alarmVolume,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      alarmVolume: alarmVolume ?? this.alarmVolume,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themePreference': themePreference.name,
      'alarmSoundId': alarmSoundId,
      'vibrationEnabled': vibrationEnabled,
      'snoozeEnabled': snoozeEnabled,
      'snoozeMinutes': snoozeMinutes,
      'maxSnoozeCount': maxSnoozeCount,
      'defaultDifficulty': defaultDifficulty.name,
      'alarmVolume': alarmVolume,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    final themeName = map['themePreference'];
    final soundId = map['alarmSoundId'];
    final snoozeMinutes = map['snoozeMinutes'];
    final maxSnoozes = map['maxSnoozeCount'];
    final difficultyName = map['defaultDifficulty'];
    final volume = map['alarmVolume'];

    final difficulty = MissionDifficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () => defaults.defaultDifficulty,
    );

    return AppSettings(
      themePreference: ThemePreference.values.firstWhere(
        (value) => value.name == themeName,
        orElse: () => ThemePreference.light,
      ),
      alarmSoundId: soundId is String && soundId.isNotEmpty
          ? soundId
          : 'default',
      vibrationEnabled: map['vibrationEnabled'] is bool
          ? map['vibrationEnabled'] as bool
          : defaults.vibrationEnabled,
      snoozeEnabled: map['snoozeEnabled'] is bool
          ? map['snoozeEnabled'] as bool
          : defaults.snoozeEnabled,
      snoozeMinutes: snoozeMinutes is num && snoozeMinutes.toInt() > 0
          ? snoozeMinutes.toInt()
          : defaults.snoozeMinutes,
      maxSnoozeCount: maxSnoozes is num && maxSnoozes.toInt() > 0
          ? maxSnoozes.toInt()
          : defaults.maxSnoozeCount,
      defaultDifficulty: difficulty,
      alarmVolume: volume is num
          ? volume.toInt().clamp(0, 100)
          : defaults.alarmVolume,
    );
  }
}
