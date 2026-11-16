import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/shake/services/shake_detector_service.dart';

class ShakeMissionController extends GetxController {
  ShakeMissionController({
    MissionDifficulty? difficulty,
    ShakeDetectorService? detector,
    this.autoStartDetector = true,
  }) : difficulty = difficulty ?? MissionDifficulty.easy,
       _injectedDetector = detector;

  late MissionDifficulty difficulty;
  final ShakeDetectorService? _injectedDetector;
  final bool autoStartDetector;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxInt currentShakes = 0.obs;
  late final int requiredShakes;
  late final double threshold;
  late final Duration cooldown;

  final RxDouble currentMagnitude = 0.0.obs;
  final RxBool isSensorAvailable = true.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  ShakeDetectorService? _detector;
  late DateTime _startedAt;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    requiredShakes = MissionDifficultyConfig.shakeCount(resolvedDifficulty);
    threshold = MissionDifficultyConfig.shakeAccelerationThreshold(
      resolvedDifficulty,
    );
    cooldown = MissionDifficultyConfig.shakeCooldown(resolvedDifficulty);
    startSession();
  }

  @override
  void onClose() {
    _detector?.stop();
    _detector = null;
    super.onClose();
  }

  void startSession() {
    _detector?.stop();
    currentShakes.value = 0;
    currentMagnitude.value = 0.0;
    isSensorAvailable.value = true;
    result.value = null;
    _startedAt = DateTime.now();
    status.value = MissionStatus.inProgress;

    if (!autoStartDetector) {
      return;
    }

    _detector =
        _injectedDetector ??
        ShakeDetectorService(
          threshold: threshold,
          cooldown: cooldown,
          onShake: _onShakeDetected,
          onMagnitudeUpdate: (mag) {
            currentMagnitude.value = mag;
          },
          onError: (err) {
            isSensorAvailable.value = false;
          },
        );

    _detector?.start();
  }

  void _onShakeDetected() {
    if (status.value != MissionStatus.inProgress) return;

    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }

    currentShakes.value++;
    if (currentShakes.value >= requiredShakes) {
      _completeMission();
    }
  }

  void manualShake() {
    // Fallback if physical sensor is unavailable on an emulator or desktop
    _onShakeDetected();
  }

  void _completeMission() {
    _detector?.stop();
    status.value = MissionStatus.completed;
    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.shake,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: currentShakes.value,
      attempts: currentShakes.value,
      metrics: <String, dynamic>{
        'Total shakes': '${currentShakes.value} / $requiredShakes',
        'Intensity required': '${threshold.toStringAsFixed(1)} m/s²',
      },
    );
  }
}
