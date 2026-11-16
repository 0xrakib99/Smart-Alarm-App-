import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/core/services/mission_launcher.dart';

enum AlarmState {
  idle,
  scheduled,
  ringing,
  missionInProgress,
  completed,
  snoozed,
  cancelled,
}

class AlarmStateService extends GetxService with WidgetsBindingObserver {
  AlarmStateService({
    required this.nativeService,
    required this.alarmRepository,
    this.historyRepository,
    Duration? inactivityTimeout,
    Duration? maxMissionDuration,
    DateTime Function()? nowProvider,
  }) : inactivityTimeout = inactivityTimeout ?? defaultInactivityTimeout,
       maxMissionDuration = maxMissionDuration ?? defaultMaxMissionDuration,
       _now = nowProvider ?? DateTime.now;

  static const Duration defaultInactivityTimeout = Duration(seconds: 30);
  static const Duration defaultMaxMissionDuration = Duration(minutes: 5);

  final Duration inactivityTimeout;
  final Duration maxMissionDuration;
  final DateTime Function() _now;

  final AlarmNativeService nativeService;
  final AlarmRepository alarmRepository;
  final AlarmHistoryRepository? historyRepository;

  final Rx<AlarmState> currentState = AlarmState.idle.obs;
  final Rxn<AlarmModel> activeAlarm = Rxn<AlarmModel>();
  final Rxn<MissionResult> lastMissionResult = Rxn<MissionResult>();
  final RxInt currentMissionIndex = 0.obs;
  final RxList<MissionResult> completedMissionResults = <MissionResult>[].obs;
  final RxInt remainingSnoozes = 3.obs;

  final RxBool isSoundPaused = false.obs;
  final RxBool wasSoundResumedDueToInactivity = false.obs;
  final RxBool wasSoundResumedDueToMaxDuration = false.obs;
  final RxBool areMissionsCompleted = false.obs;
  final RxnString alarmError = RxnString();

  DateTime? _ringStartedAt;
  DateTime? _missionSegmentStartedAt;
  Duration _accumulatedMissionDuration = Duration.zero;
  int _snoozeCount = 0;
  bool _isProcessingSuccess = false;

  Timer? _inactivityTimer;
  Timer? _maxDurationTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    nativeService.onAlarmTriggered = handleTrigger;
    nativeService.onAlarmError = (message) => alarmError.value = message;
    _checkActiveAlarmOnStartup();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimers();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  void _handleAppResumed() {
    if (currentState.value != AlarmState.idle &&
        currentState.value != AlarmState.snoozed) {
      final currentRoute = Get.currentRoute;
      final isRingingOrMissionRoute =
          currentRoute == AppRoutes.alarmRinging ||
          currentRoute == AppRoutes.mathMission ||
          currentRoute == AppRoutes.tapMission ||
          currentRoute == AppRoutes.memoryMission ||
          currentRoute == AppRoutes.puzzleMission ||
          currentRoute == AppRoutes.shakeMission ||
          currentRoute == AppRoutes.wordScrambleMission ||
          currentRoute == AppRoutes.colorSequenceMission ||
          currentRoute == AppRoutes.typingMission;

      if (!isRingingOrMissionRoute && activeAlarm.value != null) {
        Get.offAllNamed(AppRoutes.alarmRinging, arguments: activeAlarm.value);
      }
    }
  }

  Future<void> _checkActiveAlarmOnStartup() async {
    final activeMap = await nativeService.getActiveAlarm();
    if (activeMap != null) {
      handleTrigger(activeMap);
    }
  }

  void handleTrigger(Map<String, dynamic> alarmMap) {
    final id = alarmMap['id'] as String? ?? '';
    final existingAlarms = alarmRepository.getAlarms();
    AlarmModel? alarm = existingAlarms.firstWhereOrNull((a) => a.id == id);

    alarm ??= AlarmModel.fromMap(alarmMap);

    if (currentState.value == AlarmState.ringing &&
        activeAlarm.value?.id == alarm.id) {
      return;
    }

    _ringStartedAt ??= DateTime.now();
    _missionSegmentStartedAt = null;
    _accumulatedMissionDuration = Duration.zero;
    _isProcessingSuccess = false;
    isSoundPaused.value = false;
    wasSoundResumedDueToInactivity.value = false;
    wasSoundResumedDueToMaxDuration.value = false;
    areMissionsCompleted.value = false;
    currentMissionIndex.value = 0;
    completedMissionResults.clear();
    alarmError.value = null;

    activeAlarm.value = alarm;
    remainingSnoozes.value = 3;
    currentState.value = AlarmState.ringing;

    if (Get.currentRoute != AppRoutes.alarmRinging) {
      Get.toNamed(AppRoutes.alarmRinging, arguments: alarm);
    }
  }

  Future<void> startMission(BuildContext context) async {
    final alarm = activeAlarm.value;
    if (alarm == null) return;

    if (alarm.missions.isEmpty) {
      // Alarm has no mission configured; mark completed and allow Dismiss
      areMissionsCompleted.value = true;
      currentState.value = AlarmState.completed;
      return;
    }

    if (currentMissionIndex.value >= alarm.missions.length) {
      areMissionsCompleted.value = true;
      currentState.value = AlarmState.completed;
      return;
    }

    final mission = alarm.missions[currentMissionIndex.value];
    currentState.value = AlarmState.missionInProgress;
    _missionSegmentStartedAt ??= _now();

    if (wasSoundResumedDueToMaxDuration.value) {
      // Max cumulative mission duration exceeded: ringtone stays active
      isSoundPaused.value = false;
      await nativeService.resumeRinging();
    } else {
      // Pause audio playback while keeping foreground service alive
      await nativeService.pauseRinging();
      isSoundPaused.value = true;
      wasSoundResumedDueToInactivity.value = false;

      _startInactivityTimer();
      await _startMaxDurationTimer();
    }

    final result = await MissionLauncher.launch(mission);

    if (result != null && result.isSuccess) {
      await onMissionSuccess(result);
    } else if (currentState.value == AlarmState.missionInProgress) {
      // Mission incomplete or user navigated back; resume ringtone immediately
      await returnToAlarmScreen();
    }
  }

  Duration _currentCumulativeMissionDuration() {
    if (_missionSegmentStartedAt == null) {
      return _accumulatedMissionDuration;
    }
    return _accumulatedMissionDuration +
        _now().difference(_missionSegmentStartedAt!);
  }

  void _pauseMissionDurationTracking() {
    if (_missionSegmentStartedAt != null) {
      _accumulatedMissionDuration += _now().difference(
        _missionSegmentStartedAt!,
      );
      _missionSegmentStartedAt = null;
    }
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
  }

  void _startInactivityTimer() {
    if (wasSoundResumedDueToMaxDuration.value) {
      return;
    }
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityTimeout, () async {
      if (currentState.value == AlarmState.missionInProgress) {
        isSoundPaused.value = false;
        wasSoundResumedDueToInactivity.value = true;
        await nativeService.resumeRinging();
      }
    });
  }

  Future<void> _startMaxDurationTimer() async {
    if (wasSoundResumedDueToMaxDuration.value) {
      return;
    }
    _maxDurationTimer?.cancel();
    final remaining = maxMissionDuration - _currentCumulativeMissionDuration();
    if (remaining <= Duration.zero) {
      _inactivityTimer?.cancel();
      isSoundPaused.value = false;
      wasSoundResumedDueToInactivity.value = false;
      wasSoundResumedDueToMaxDuration.value = true;
      await nativeService.resumeRinging();
      return;
    }
    _maxDurationTimer = Timer(remaining, () async {
      if (currentState.value == AlarmState.missionInProgress) {
        _inactivityTimer?.cancel();
        isSoundPaused.value = false;
        wasSoundResumedDueToInactivity.value = false;
        wasSoundResumedDueToMaxDuration.value = true;
        await nativeService.resumeRinging();
      }
    });
  }

  void reportMissionInteraction() {
    if (wasSoundResumedDueToMaxDuration.value) {
      // Interaction cannot reset max duration limit
      return;
    }

    if (currentState.value == AlarmState.missionInProgress &&
        isSoundPaused.value) {
      _startInactivityTimer();
    }
  }

  Future<void> continueMission() async {
    if (wasSoundResumedDueToMaxDuration.value) {
      // Max duration reached; ringtone must remain active
      return;
    }

    final alarm = activeAlarm.value;
    if (alarm == null || alarm.missions.isEmpty) return;

    if (currentMissionIndex.value >= alarm.missions.length) {
      areMissionsCompleted.value = true;
      currentState.value = AlarmState.completed;
      return;
    }

    final mission = alarm.missions[currentMissionIndex.value];
    currentState.value = AlarmState.missionInProgress;
    _missionSegmentStartedAt ??= _now();
    wasSoundResumedDueToInactivity.value = false;
    isSoundPaused.value = true;
    await nativeService.pauseRinging();
    _startInactivityTimer();
    await _startMaxDurationTimer();

    final route = MissionLauncher.routeFor(mission.type);
    if (Get.currentRoute != route) {
      final result = await MissionLauncher.launch(mission);
      if (result != null && result.isSuccess) {
        await onMissionSuccess(result);
      } else if (currentState.value == AlarmState.missionInProgress) {
        await returnToAlarmScreen();
      }
    }
  }

  Future<void> returnToAlarmScreen() async {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _pauseMissionDurationTracking();
    isSoundPaused.value = false;
    wasSoundResumedDueToInactivity.value = false;
    if (currentState.value == AlarmState.missionInProgress) {
      currentState.value = AlarmState.ringing;
    }
    await nativeService.resumeRinging();

    if (Get.currentRoute != AppRoutes.alarmRinging) {
      Get.offNamedUntil(
        AppRoutes.alarmRinging,
        (route) => route.settings.name == AppRoutes.home,
        arguments: activeAlarm.value,
      );
    }
  }

  Future<void> onMissionSuccess(MissionResult result) async {
    if (_isProcessingSuccess) return;
    if (!result.isSuccess) return;
    _isProcessingSuccess = true;

    _cancelTimers();
    lastMissionResult.value = result;
    completedMissionResults.add(result);
    currentMissionIndex.value++;

    final alarm = activeAlarm.value;
    final totalRequired = alarm?.missions.length ?? 1;

    if (currentMissionIndex.value < totalRequired) {
      // More missions remain in this multi-mission sequence
      _isProcessingSuccess = false;
      areMissionsCompleted.value = false;
      currentState.value = AlarmState.ringing;
      isSoundPaused.value = false;
      await nativeService.resumeRinging();
    } else {
      // All required missions are completed
      areMissionsCompleted.value = true;
      currentState.value = AlarmState.completed;
      isSoundPaused.value = false;
      await nativeService.resumeRinging();
    }

    // Navigate to alarm ringing screen if not already there, showing completion summary or next mission
    if (Get.currentRoute != AppRoutes.alarmRinging) {
      Get.offNamedUntil(
        AppRoutes.alarmRinging,
        (route) => route.settings.name == AppRoutes.home,
        arguments: activeAlarm.value,
      );
    }
  }

  Future<void> finishAndDismiss() async {
    final alarm = activeAlarm.value;

    // Strict validation: Reject dismiss if alarm required missions and they are not complete
    if (alarm?.missions.isNotEmpty == true && !areMissionsCompleted.value) {
      return;
    }

    _cancelTimers();

    // 1. Stop audio playback and foreground service
    await nativeService.stopRinging();

    // 2. Log history record
    if (alarm != null) {
      final totalDuration = completedMissionResults.fold<int>(
        0,
        (sum, r) => sum + r.duration.inSeconds,
      );

      final record = AlarmHistoryRecord(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        alarmId: alarm.id,
        alarmLabel: alarm.label.trim().isEmpty ? 'Alarm' : alarm.label,
        scheduledTime: _ringStartedAt ?? DateTime.now(),
        actualTime: DateTime.now(),
        status: AlarmHistoryStatus.completed,
        selectedMissions: alarm.missions.isNotEmpty
            ? alarm.missions.map((m) => m.type.name).toList()
            : const <String>[],
        completedMissions: completedMissionResults.isNotEmpty
            ? completedMissionResults.map((r) => r.type.name).toList()
            : (lastMissionResult.value != null
                  ? <String>[lastMissionResult.value!.type.name]
                  : const <String>[]),
        durationSeconds: totalDuration > 0
            ? totalDuration
            : (lastMissionResult.value?.duration.inSeconds ?? 0),
        snoozeCount: _snoozeCount,
        difficulty:
            lastMissionResult.value?.difficulty.name ??
            alarm.mission?.difficulty.name,
      );
      await historyRepository?.addRecord(record);

      // 3. Disable one-time alarm or schedule next occurrence
      if (alarm.repeatDays.isEmpty) {
        await alarmRepository.setEnabled(alarm.id, false);
      } else {
        await nativeService.scheduleAlarm(alarm);
      }
    }

    // 4. Clear active session state
    _ringStartedAt = null;
    _missionSegmentStartedAt = null;
    _accumulatedMissionDuration = Duration.zero;
    _snoozeCount = 0;
    _isProcessingSuccess = false;
    isSoundPaused.value = false;
    wasSoundResumedDueToInactivity.value = false;
    wasSoundResumedDueToMaxDuration.value = false;
    areMissionsCompleted.value = false;
    currentMissionIndex.value = 0;
    completedMissionResults.clear();
    alarmError.value = null;
    activeAlarm.value = null;
    lastMissionResult.value = null;
    currentState.value = AlarmState.idle;

    // 5. Navigate safely home
    Get.offAllNamed(AppRoutes.home);
  }

  void _cancelTimers() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
  }
}
