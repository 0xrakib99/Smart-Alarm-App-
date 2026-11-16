import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';

class TapMissionController extends GetxController {
  TapMissionController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxInt successfulTaps = 0.obs;
  late final int targetCount;
  late final Duration targetDuration;
  late final double targetSize;

  // Normalized relative positions [0.0, 1.0] inside the play area
  final RxDouble targetNormX = 0.5.obs;
  final RxDouble targetNormY = 0.5.obs;
  final RxBool isTargetVisible = true.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  final Random _random = Random();
  late DateTime _startedAt;
  int _missedTaps = 0;
  int _totalAttempts = 0;
  Timer? _targetTimer;

  int get missedTaps => _missedTaps;
  int get totalAttempts => _totalAttempts;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    targetCount = MissionDifficultyConfig.tapTargetCount(resolvedDifficulty);
    targetDuration = MissionDifficultyConfig.tapTargetDuration(
      resolvedDifficulty,
    );
    targetSize = MissionDifficultyConfig.tapTargetSize(resolvedDifficulty);
    startSession();
  }

  @override
  void onClose() {
    _targetTimer?.cancel();
    super.onClose();
  }

  void startSession() {
    _targetTimer?.cancel();
    successfulTaps.value = 0;
    _missedTaps = 0;
    _totalAttempts = 0;
    result.value = null;
    _startedAt = DateTime.now();
    status.value = MissionStatus.inProgress;
    _spawnNextTarget();
  }

  void _spawnNextTarget() {
    _targetTimer?.cancel();
    if (status.value != MissionStatus.inProgress) {
      return;
    }

    // Pick new random normalized position [0.08, 0.92] to avoid screen edges
    targetNormX.value = 0.08 + (_random.nextDouble() * 0.84);
    targetNormY.value = 0.08 + (_random.nextDouble() * 0.84);
    isTargetVisible.value = true;

    _targetTimer = Timer(targetDuration, () {
      if (status.value == MissionStatus.inProgress) {
        _missedTaps++;
        _spawnNextTarget();
      }
    });
  }

  void onTapTarget() {
    if (status.value != MissionStatus.inProgress) {
      return;
    }

    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }

    _totalAttempts++;
    successfulTaps.value++;

    if (successfulTaps.value >= targetCount) {
      _completeMission();
    } else {
      _spawnNextTarget();
    }
  }

  void onMissedPlayAreaTap() {
    if (status.value != MissionStatus.inProgress) {
      return;
    }
    _totalAttempts++;
    _missedTaps++;
  }

  void _completeMission() {
    _targetTimer?.cancel();
    status.value = MissionStatus.completed;
    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.tap,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: successfulTaps.value,
      attempts: _totalAttempts,
      metrics: <String, dynamic>{
        'Targets hit': '${successfulTaps.value} / $targetCount',
        'Missed attempts': '$_missedTaps',
      },
    );
  }
}
