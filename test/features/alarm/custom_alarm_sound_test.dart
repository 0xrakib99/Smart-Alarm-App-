import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_sounds.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';
import 'package:smart_alarm/features/alarm/controllers/create_alarm_controller.dart';
import 'package:smart_alarm/features/alarm/presentation/widgets/sound_selection_sheet.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';

class _FakeAlarmRepository implements AlarmRepository {
  final Map<String, AlarmModel> _alarms = <String, AlarmModel>{};

  @override
  List<AlarmModel> getAlarms() => _alarms.values.toList();

  AlarmModel? getAlarm(String id) => _alarms[id];

  @override
  Future<bool> saveAlarm(AlarmModel alarm) async {
    _alarms[alarm.id] = alarm;
    return true;
  }

  @override
  Future<bool> deleteAlarm(String id) async {
    _alarms.remove(id);
    return true;
  }

  @override
  Future<bool> setEnabled(String id, bool enabled) async {
    final existing = _alarms[id];
    if (existing == null) return false;
    _alarms[id] = existing.copyWith(enabled: enabled);
    return true;
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  AppSettings load() => _settings;

  @override
  Future<bool> save(AppSettings settings) async {
    _settings = settings;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAlarmRepository alarmRepo;
  late _FakeSettingsRepository settingsRepo;
  late SettingsController settingsController;

  setUp(() {
    Get.reset();
    alarmRepo = _FakeAlarmRepository();
    settingsRepo = _FakeSettingsRepository();
    Get.put<SettingsRepository>(settingsRepo);
    settingsController = Get.put(SettingsController(settingsRepo));
  });

  tearDown(() {
    Get.reset();
  });

  group('AlarmModel Custom Sound Serialization', () {
    test('Serializes and deserializes customSoundPath and customSoundName', () {
      final alarm = AlarmModel(
        id: 'test_1',
        hour: 6,
        minute: 30,
        label: 'Work',
        repeatDays: const <int>[1, 2, 3],
        soundId: 'custom',
        customSoundPath: '/data/user/0/app/files/custom_sounds/morning.mp3',
        customSoundName: 'morning.mp3',
        vibrationEnabled: true,
        snoozeEnabled: false,
        snoozeMinutes: 5,
        enabled: true,
        createdAt: DateTime(2026, 1, 1),
      );

      expect(alarm.isCustomSound, isTrue);

      final map = alarm.toMap();
      expect(map['soundId'], 'custom');
      expect(
        map['customSoundPath'],
        '/data/user/0/app/files/custom_sounds/morning.mp3',
      );
      expect(map['customSoundName'], 'morning.mp3');

      final restored = AlarmModel.fromMap(map);
      expect(restored.soundId, 'custom');
      expect(
        restored.customSoundPath,
        '/data/user/0/app/files/custom_sounds/morning.mp3',
      );
      expect(restored.customSoundName, 'morning.mp3');
      expect(restored.isCustomSound, isTrue);
    });

    test('Backward compatibility: handles missing custom sound fields', () {
      final legacyMap = <String, dynamic>{
        'id': 'legacy_1',
        'hour': 7,
        'minute': 0,
        'label': 'Legacy Alarm',
        'repeatDays': <int>[1, 2],
        'soundId': 'chime',
        'vibrationEnabled': true,
        'snoozeEnabled': true,
        'snoozeMinutes': 5,
        'enabled': true,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      };

      final alarm = AlarmModel.fromMap(legacyMap);
      expect(alarm.soundId, 'chime');
      expect(alarm.customSoundPath, isNull);
      expect(alarm.customSoundName, isNull);
      expect(alarm.isCustomSound, isFalse);
    });

    test('copyWith updates custom sound or clears it', () {
      final alarm = AlarmModel(
        id: 'test_2',
        hour: 8,
        minute: 0,
        label: 'Alarm',
        repeatDays: const <int>[],
        soundId: 'custom',
        customSoundPath: '/path/sound.mp3',
        customSoundName: 'sound.mp3',
        vibrationEnabled: true,
        snoozeEnabled: false,
        snoozeMinutes: 5,
        enabled: true,
        createdAt: DateTime.now(),
      );

      final updated = alarm.copyWith(
        soundId: 'default',
        clearCustomSound: true,
      );

      expect(updated.soundId, 'default');
      expect(updated.customSoundPath, isNull);
      expect(updated.customSoundName, isNull);
      expect(updated.isCustomSound, isFalse);
    });
  });

  group('AppSounds nameFor and built-in list', () {
    test('nameFor returns custom sound name when provided', () {
      expect(
        AppSounds.nameFor('custom', customName: 'My Favorite Song.mp3'),
        'My Favorite Song.mp3',
      );
      expect(AppSounds.nameFor('siren'), 'Siren (Emergency)');
      expect(AppSounds.nameFor('default'), 'Default System Sound');
      expect(AppSounds.nameFor('unknown_id'), 'Default System Sound');
    });
  });

  group('CreateAlarmController Custom Sound Management', () {
    test('sets and saves custom sound selection', () async {
      final controller = CreateAlarmController(
        alarmRepo,
        settingsController: settingsController,
      );

      expect(controller.isCustomSound, isFalse);
      expect(controller.soundName, 'Default System Sound');

      controller.setSoundSelection(
        id: 'custom',
        customPath: '/data/app/custom.wav',
        customName: 'Custom Melody.wav',
      );

      expect(controller.isCustomSound, isTrue);
      expect(controller.soundId.value, 'custom');
      expect(controller.customSoundPath.value, '/data/app/custom.wav');
      expect(controller.customSoundName.value, 'Custom Melody.wav');
      expect(controller.soundName, 'Custom Melody.wav');

      final saved = await controller.save();
      expect(saved, isTrue);

      final savedAlarms = alarmRepo.getAlarms();
      expect(savedAlarms.length, 1);
      expect(savedAlarms.first.soundId, 'custom');
      expect(savedAlarms.first.customSoundPath, '/data/app/custom.wav');
      expect(savedAlarms.first.customSoundName, 'Custom Melody.wav');

      // Revert to built-in sound
      controller.setSound('chime');
      expect(controller.isCustomSound, isFalse);
      expect(controller.soundId.value, 'chime');
      expect(controller.customSoundPath.value, isNull);

      controller.onClose();
    });

    test('initializes from editing alarm with custom sound', () {
      final existingAlarm = AlarmModel(
        id: 'edit_custom',
        hour: 7,
        minute: 15,
        label: 'Custom Alarm',
        repeatDays: const <int>[],
        soundId: 'custom',
        customSoundPath: '/storage/alarm.m4a',
        customSoundName: 'alarm.m4a',
        vibrationEnabled: true,
        snoozeEnabled: false,
        snoozeMinutes: 5,
        enabled: true,
        createdAt: DateTime.now(),
      );

      final controller = CreateAlarmController(
        alarmRepo,
        settingsController: settingsController,
        alarm: existingAlarm,
      );

      expect(controller.isEditing, isTrue);
      expect(controller.isCustomSound, isTrue);
      expect(controller.soundId.value, 'custom');
      expect(controller.customSoundPath.value, '/storage/alarm.m4a');
      expect(controller.customSoundName.value, 'alarm.m4a');
      expect(controller.soundName, 'alarm.m4a');

      controller.onClose();
    });
  });

  group('AlarmNativeService Audio Preview & Custom Sound', () {
    test('pickCustomSound parses platform response correctly', () async {
      final nativeService = Get.put(AlarmNativeService());
      final channel = const MethodChannel(
        'com.jihan.dreamalarm.smart_alarm/alarm',
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'pickCustomSound') {
              return <String, dynamic>{
                'path': '/data/user/0/app/files/custom_sounds/sound_123.mp3',
                'name': 'My Song.mp3',
                'size': 204800,
                'duration': 45000,
              };
            } else if (call.method == 'playAudioPreview') {
              return true;
            } else if (call.method == 'stopAudioPreview') {
              return true;
            }
            return null;
          });

      final picked = await nativeService.pickCustomSound();
      expect(picked, isNotNull);
      expect(
        picked!.path,
        '/data/user/0/app/files/custom_sounds/sound_123.mp3',
      );
      expect(picked.name, 'My Song.mp3');
      expect(picked.size, 204800);
      expect(picked.durationMs, 45000);

      final playSuccess = await nativeService.playAudioPreview(
        path: picked.path,
        volumePercent: 80,
      );
      expect(playSuccess, isTrue);

      final stopSuccess = await nativeService.stopAudioPreview();
      expect(stopSuccess, isTrue);
    });
  });

  group('SoundSelectionSheet Widget Tests', () {
    testWidgets('renders device audio button and built-in sounds', (
      tester,
    ) async {
      Get.put(AlarmNativeService());
      final channel = const MethodChannel(
        'com.jihan.dreamalarm.smart_alarm/alarm',
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'stopAudioPreview') {
              return true;
            }
            return true;
          });

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    SoundSelectionSheet.show(ctx, currentSoundId: 'default');
                  },
                  child: const Text('Open Sounds'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sounds'));
      await tester.pumpAndSettle();

      expect(find.text('Alarm sound'), findsOneWidget);
      expect(find.text('DEVICE AUDIO'), findsOneWidget);
      expect(find.text('Select custom audio from device'), findsOneWidget);
      expect(find.text('BUILT-IN ALARM SOUNDS'), findsOneWidget);
      expect(find.text('Default System Sound'), findsOneWidget);
      expect(find.text('Siren (Emergency)'), findsOneWidget);
      expect(find.text('Gentle Chime'), findsOneWidget);
      expect(find.text('Save selection'), findsOneWidget);

      // Tap built-in sound row
      await tester.tap(find.text('Gentle Chime'));
      await tester.pumpAndSettle();

      // Apply selection
      await tester.tap(find.text('Save selection'));
      await tester.pumpAndSettle();

      expect(find.text('DEVICE AUDIO'), findsNothing);
    });

    testWidgets(
      'renders custom sound card with preview button when populated',
      (tester) async {
        Get.put(AlarmNativeService());
        final channel = const MethodChannel(
          'com.jihan.dreamalarm.smart_alarm/alarm',
        );

        String? lastPlayedPath;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'playAudioPreview') {
                lastPlayedPath = (call.arguments as Map)['path'] as String?;
                return true;
              } else if (call.method == 'stopAudioPreview') {
                return true;
              }
              return true;
            });

        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundSelectionSheet.show(
                        ctx,
                        currentSoundId: 'custom',
                        currentCustomPath: '/storage/music/wake.mp3',
                        currentCustomName: 'wake.mp3',
                      );
                    },
                    child: const Text('Open Sounds'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sounds'));
        await tester.pumpAndSettle();

        expect(find.text('wake.mp3'), findsOneWidget);
        expect(find.text('Saved in app private storage'), findsOneWidget);

        // Tap Play preview on the custom sound
        final playIcon = find.byIcon(Icons.play_circle_fill_rounded);
        expect(playIcon, findsOneWidget);
        await tester.tap(playIcon);
        await tester.pumpAndSettle();

        expect(lastPlayedPath, '/storage/music/wake.mp3');
        expect(find.byIcon(Icons.stop_circle_rounded), findsOneWidget);

        // Close sheet
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
      },
    );
  });
}
