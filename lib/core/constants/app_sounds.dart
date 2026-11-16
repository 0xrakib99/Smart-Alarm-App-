import 'package:smart_alarm/data/models/alarm_sound.dart';

abstract final class AppSounds {
  static const AlarmSound defaultSound = AlarmSound(
    id: 'default',
    name: 'Default System Sound',
  );

  static const List<AlarmSound> builtIn = <AlarmSound>[
    defaultSound,
    AlarmSound(id: 'siren', name: 'Siren (Emergency)'),
    AlarmSound(id: 'chime', name: 'Gentle Chime'),
    AlarmSound(id: 'pulse', name: 'Pulse Beat'),
    AlarmSound(id: 'bell', name: 'Morning Bell'),
    AlarmSound(id: 'beacon', name: 'Beacon Alert'),
  ];

  static List<AlarmSound> get all => builtIn;

  static String nameFor(String id, {String? customName}) {
    if (id == 'custom' && customName != null && customName.isNotEmpty) {
      return customName;
    }
    return builtIn
        .firstWhere((sound) => sound.id == id, orElse: () => defaultSound)
        .name;
  }
}
