import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';

typedef AlarmTriggerCallback = void Function(Map<String, dynamic> alarmData);
typedef AlarmErrorCallback = void Function(String message);
typedef AudioPreviewStoppedCallback = void Function();

class CustomSoundResult {
  const CustomSoundResult({
    required this.path,
    required this.name,
    this.size = 0,
    this.durationMs = 0,
  });

  final String path;
  final String name;
  final int size;
  final int durationMs;

  factory CustomSoundResult.fromMap(Map<dynamic, dynamic> map) {
    return CustomSoundResult(
      path: map['path'] is String ? map['path'] as String : '',
      name: map['name'] is String ? map['name'] as String : 'Custom Sound',
      size: map['size'] is num ? (map['size'] as num).toInt() : 0,
      durationMs: map['duration'] is num ? (map['duration'] as num).toInt() : 0,
    );
  }
}

class AlarmNativeService extends GetxService {
  static const MethodChannel _channel = MethodChannel(
    'com.jihan.dreamalarm.smart_alarm/alarm',
  );

  AlarmTriggerCallback? onAlarmTriggered;
  AlarmErrorCallback? onAlarmError;
  AudioPreviewStoppedCallback? onAudioPreviewStopped;
  final RxnString lastNativeError = RxnString();

  @override
  void onInit() {
    super.onInit();
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    if (call.method == 'onAlarmTriggered') {
      final args = call.arguments;
      if (args is Map) {
        final map = Map<String, dynamic>.from(args);
        onAlarmTriggered?.call(map);
      }
    } else if (call.method == 'onAlarmError') {
      final message = call.arguments is String
          ? call.arguments as String
          : 'Native alarm playback reported an error.';
      lastNativeError.value = message;
      developer.log(message, name: 'AlarmNativeService');
      onAlarmError?.call(message);
    } else if (call.method == 'onAudioPreviewStopped') {
      onAudioPreviewStopped?.call();
    }
  }

  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.enabled) {
      await cancelAlarm(alarm.id);
      return true;
    }

    final nextOccurrence = AppDateUtils.nextOccurrence(alarm, DateTime.now());

    if (nextOccurrence == null) {
      return false;
    }

    final map = alarm.toMap();
    map['triggerTimeMillis'] = nextOccurrence.millisecondsSinceEpoch;
    map['volume'] = _configuredAlarmVolume();

    try {
      final success = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'alarm': map,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancelAlarm(String id) async {
    try {
      final success = await _channel.invokeMethod<bool>('cancelAlarm', {
        'id': id,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> syncAlarms(List<AlarmModel> alarms) async {
    final list = <Map<String, dynamic>>[];
    for (final alarm in alarms) {
      final map = alarm.toMap();
      map['volume'] = _configuredAlarmVolume();
      if (alarm.enabled) {
        final nextOccurrence = AppDateUtils.nextOccurrence(
          alarm,
          DateTime.now(),
        );
        if (nextOccurrence != null) {
          map['triggerTimeMillis'] = nextOccurrence.millisecondsSinceEpoch;
        }
      }
      list.add(map);
    }

    try {
      final success = await _channel.invokeMethod<bool>('syncAlarms', {
        'alarms': list,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pauseRinging() async {
    try {
      final success = await _channel.invokeMethod<bool>('pauseAlarmAudio');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resumeRinging() async {
    try {
      final success = await _channel.invokeMethod<bool>('resumeAlarmAudio');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopRinging() async {
    try {
      final success = await _channel.invokeMethod<bool>('stopAlarm');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> snooze(String id, int snoozeMinutes) async {
    try {
      final success = await _channel.invokeMethod<bool>('snoozeAlarm', {
        'id': id,
        'snoozeMinutes': snoozeMinutes,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  int _configuredAlarmVolume() {
    if (Get.isRegistered<SettingsRepository>()) {
      return Get.find<SettingsRepository>().load().alarmVolume.clamp(10, 100);
    }
    return 80;
  }

  Future<Map<String, dynamic>?> getActiveAlarm() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getActiveAlarm',
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<CustomSoundResult?> pickCustomSound() async {
    try {
      final res = await _channel.invokeMapMethod<dynamic, dynamic>(
        'pickCustomSound',
      );
      if (res != null) {
        return CustomSoundResult.fromMap(res);
      }
      return null;
    } on PlatformException catch (e) {
      lastNativeError.value = e.message ?? 'Failed to pick audio file';
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> playAudioPreview({
    String? path,
    String? soundId,
    int? volumePercent,
  }) async {
    try {
      final success = await _channel.invokeMethod<bool>('playAudioPreview', {
        'path': path,
        'soundId': soundId,
        'volume': volumePercent ?? _configuredAlarmVolume(),
      });
      return success ?? false;
    } on PlatformException catch (e) {
      lastNativeError.value = e.message;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pauseAudioPreview() async {
    try {
      final success = await _channel.invokeMethod<bool>('pauseAudioPreview');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resumeAudioPreview() async {
    try {
      final success = await _channel.invokeMethod<bool>('resumeAudioPreview');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopAudioPreview() async {
    try {
      final success = await _channel.invokeMethod<bool>('stopAudioPreview');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }
}
