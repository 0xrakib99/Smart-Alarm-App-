import 'package:smart_alarm/data/models/mission_config.dart';

class AlarmModel {
  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    required List<int> repeatDays,
    required this.soundId,
    this.customSoundPath,
    this.customSoundName,
    required this.vibrationEnabled,
    required this.snoozeEnabled,
    required this.snoozeMinutes,
    required this.enabled,
    required this.createdAt,
    MissionConfig? mission,
    List<MissionConfig>? missions,
  }) : missions = missions != null
           ? List<MissionConfig>.unmodifiable(missions)
           : (mission != null
                 ? List<MissionConfig>.unmodifiable(<MissionConfig>[mission])
                 : const <MissionConfig>[]),
       repeatDays = List<int>.unmodifiable(
         (repeatDays.toSet().toList()..sort()),
       );

  final String id;
  final int hour;
  final int minute;
  final String label;

  /// Uses [DateTime] weekday values: Monday = 1 through Sunday = 7.
  final List<int> repeatDays;
  final String soundId;
  final String? customSoundPath;
  final String? customSoundName;
  final bool vibrationEnabled;
  final bool snoozeEnabled;
  final int snoozeMinutes;
  final bool enabled;
  final DateTime createdAt;
  final List<MissionConfig> missions;

  bool get isCustomSound =>
      customSoundPath != null && customSoundPath!.isNotEmpty;

  MissionConfig? get mission => missions.isNotEmpty ? missions.first : null;

  static String generateId() {
    return 'alarm_${DateTime.now().microsecondsSinceEpoch}';
  }

  AlarmModel copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    List<int>? repeatDays,
    String? soundId,
    String? customSoundPath,
    String? customSoundName,
    bool clearCustomSound = false,
    bool? vibrationEnabled,
    bool? snoozeEnabled,
    int? snoozeMinutes,
    bool? enabled,
    DateTime? createdAt,
    MissionConfig? mission,
    List<MissionConfig>? missions,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      soundId: soundId ?? this.soundId,
      customSoundPath: clearCustomSound
          ? null
          : (customSoundPath ?? this.customSoundPath),
      customSoundName: clearCustomSound
          ? null
          : (customSoundName ?? this.customSoundName),
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      missions:
          missions ??
          (mission != null ? <MissionConfig>[mission] : this.missions),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'repeatDays': repeatDays,
      'soundId': soundId,
      'customSoundPath': customSoundPath,
      'customSoundName': customSoundName,
      'vibrationEnabled': vibrationEnabled,
      'snoozeEnabled': snoozeEnabled,
      'snoozeMinutes': snoozeMinutes,
      'enabled': enabled,
      'createdAt': createdAt.toIso8601String(),
      'mission': mission?.toMap(),
      'missions': missions.map((m) => m.toMap()).toList(growable: false),
    };
  }

  factory AlarmModel.fromMap(Map<dynamic, dynamic> map) {
    final repeatDays = <int>[];
    final rawRepeatDays = map['repeatDays'];
    if (rawRepeatDays is List) {
      for (final day in rawRepeatDays) {
        if (day is num) {
          final value = day.toInt();
          if (value >= DateTime.monday && value <= DateTime.sunday) {
            repeatDays.add(value);
          }
        }
      }
    }

    final rawMissions = map['missions'];
    final parsedMissions = <MissionConfig>[];
    if (rawMissions is List) {
      for (final item in rawMissions) {
        if (item is Map) {
          parsedMissions.add(MissionConfig.fromMap(item));
        }
      }
    } else if (map['mission'] is Map) {
      parsedMissions.add(MissionConfig.fromMap(map['mission'] as Map));
    }

    final rawCreatedAt = map['createdAt'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;

    return AlarmModel(
      id: map['id'] is String && (map['id'] as String).isNotEmpty
          ? map['id'] as String
          : generateId(),
      hour: _readInt(map['hour'], 7).clamp(0, 23).toInt(),
      minute: _readInt(map['minute'], 0).clamp(0, 59).toInt(),
      label: map['label'] is String ? map['label'] as String : '',
      repeatDays: repeatDays,
      soundId: map['soundId'] is String ? map['soundId'] as String : 'default',
      customSoundPath: map['customSoundPath'] is String
          ? map['customSoundPath'] as String
          : null,
      customSoundName: map['customSoundName'] is String
          ? map['customSoundName'] as String
          : null,
      vibrationEnabled: map['vibrationEnabled'] is bool
          ? map['vibrationEnabled'] as bool
          : true,
      snoozeEnabled: map['snoozeEnabled'] is bool
          ? map['snoozeEnabled'] as bool
          : true,
      snoozeMinutes: _readInt(map['snoozeMinutes'], 5).clamp(1, 60).toInt(),
      enabled: map['enabled'] is bool ? map['enabled'] as bool : true,
      createdAt: createdAt ?? DateTime.now(),
      missions: parsedMissions,
    );
  }

  static int _readInt(dynamic value, int fallback) {
    return value is num ? value.toInt() : fallback;
  }
}
