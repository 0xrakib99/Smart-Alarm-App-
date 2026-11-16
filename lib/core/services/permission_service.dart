import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PermissionService extends GetxService with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel(
    'com.jihan.dreamalarm.smart_alarm/alarm',
  );

  final RxBool exactAlarmGranted = true.obs;
  final RxBool notificationGranted = true.obs;
  final RxBool fullScreenIntentGranted = true.obs;
  final RxBool hasCheckedPermissions = false.obs;

  bool get hasAllRequiredPermissions =>
      exactAlarmGranted.value && notificationGranted.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    checkPermissions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermissions();
    }
  }

  Future<void> checkPermissions() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'checkPermissions',
      );
      if (result != null) {
        exactAlarmGranted.value = result['exactAlarm'] as bool? ?? true;
        notificationGranted.value = result['notification'] as bool? ?? true;
        fullScreenIntentGranted.value =
            result['fullScreenIntent'] as bool? ?? true;
      }
    } catch (e) {
      // Graceful fallback for tests or non-Android runtimes
      developer.log(
        'Permission check unavailable on this platform: $e',
        name: 'PermissionService',
      );
    } finally {
      hasCheckedPermissions.value = true;
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      final allowed = await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      final value = allowed ?? true;
      exactAlarmGranted.value = value;
      return value;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      developer.log(
        'Failed to open exact alarm settings: $e',
        name: 'PermissionService',
      );
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      await _channel.invokeMethod('requestNotificationPermission');
    } catch (e) {
      developer.log(
        'Failed to request notification permission: $e',
        name: 'PermissionService',
      );
    }
  }

  Future<void> requestFullScreenIntentPermission() async {
    try {
      await _channel.invokeMethod('requestFullScreenIntentPermission');
    } catch (e) {
      developer.log(
        'Failed to open full-screen intent settings: $e',
        name: 'PermissionService',
      );
    }
  }

  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e) {
      developer.log(
        'Failed to open app details settings: $e',
        name: 'PermissionService',
      );
    }
  }
}
