import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/color_sequence/models/sequence_color.dart';

class ColorSequenceController extends GetxController {
  ColorSequenceController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  late final int targetLength;

  final RxList<SequenceColor> targetSequence = <SequenceColor>[].obs;
  final RxInt currentRound = 1.obs;
  final RxList<SequenceColor> userInputs = <SequenceColor>[].obs;

  final RxBool isDemonstrating = false.obs;
  final Rxn<SequenceColor> activeFlashColor = Rxn<SequenceColor>();
  final RxnString feedbackMessage = RxnString();
  final RxBool hasError = false.obs;

  final RxInt moves = 0.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  late DateTime _startedAt;
  Timer? _playbackTimer;
  Timer? _flashOffTimer;
  int _demoIndex = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    targetLength = MissionDifficultyConfig.colorSequenceLength(
      resolvedDifficulty,
    );
    startSession();
  }

  void startSession() {
    _cancelTimers();
    result.value = null;
    moves.value = 0;
    _startedAt = DateTime.now();
    currentRound.value = 1;

    final rng = Random();
    final colors = SequenceColor.values;
    final list = <SequenceColor>[];
    for (int i = 0; i < targetLength; i++) {
      list.add(colors[rng.nextInt(colors.length)]);
    }
    targetSequence.assignAll(list);
    status.value = MissionStatus.inProgress;

    // Small initial delay before demo begins
    _playbackTimer = Timer(const Duration(milliseconds: 600), () {
      playSequenceDemo();
    });
  }

  void playSequenceDemo() {
    if (status.value != MissionStatus.inProgress) return;
    _cancelTimers();
    isDemonstrating.value = true;
    hasError.value = false;
    userInputs.clear();
    feedbackMessage.value = 'Watch the sequence...';
    _demoIndex = 0;

    _stepDemo();
  }

  void _stepDemo() {
    if (status.value != MissionStatus.inProgress) return;
    if (_demoIndex >= currentRound.value) {
      isDemonstrating.value = false;
      activeFlashColor.value = null;
      feedbackMessage.value = 'Your turn! Tap the colors in order.';
      return;
    }

    final color = targetSequence[_demoIndex];
    activeFlashColor.value = color;

    final flashDuration = MissionDifficultyConfig.colorSequenceFlashDuration(
      difficulty,
    );
    _flashOffTimer = Timer(flashDuration, () {
      activeFlashColor.value = null;
      _demoIndex++;
      _playbackTimer = Timer(const Duration(milliseconds: 200), () {
        _stepDemo();
      });
    });
  }

  void tapColor(SequenceColor color) {
    if (status.value != MissionStatus.inProgress) return;
    if (isDemonstrating.value) return; // Inputs strictly locked during playback

    _reportInteraction();
    moves.value++;

    // Quick visual flash for tap response
    activeFlashColor.value = color;
    Timer(const Duration(milliseconds: 150), () {
      if (!isDemonstrating.value) {
        activeFlashColor.value = null;
      }
    });

    final expectedIndex = userInputs.length;
    if (expectedIndex >= currentRound.value) return;

    final expectedColor = targetSequence[expectedIndex];
    if (color == expectedColor) {
      userInputs.add(color);
      hasError.value = false;

      if (userInputs.length == currentRound.value) {
        // Round completed successfully!
        if (currentRound.value >= targetLength) {
          _completeMission();
        } else {
          feedbackMessage.value =
              'Round ${currentRound.value} complete! Get ready...';
          currentRound.value++;
          isDemonstrating.value = true;
          _playbackTimer = Timer(const Duration(milliseconds: 800), () {
            playSequenceDemo();
          });
        }
      }
    } else {
      // Incorrect color tapped!
      hasError.value = true;
      feedbackMessage.value = 'Incorrect color! Watch again.';
      isDemonstrating.value = true;
      _playbackTimer = Timer(const Duration(milliseconds: 1000), () {
        playSequenceDemo();
      });
    }
  }

  void _completeMission() {
    _cancelTimers();
    activeFlashColor.value = null;
    isDemonstrating.value = false;
    status.value = MissionStatus.completed;

    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.colorSequence,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: moves.value,
      attempts: currentRound.value,
      metrics: <String, dynamic>{
        'Sequence length': '$targetLength colors',
        'Rounds survived': '${currentRound.value}/$targetLength',
      },
    );
  }

  void _reportInteraction() {
    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }
  }

  void _cancelTimers() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _flashOffTimer?.cancel();
    _flashOffTimer = null;
  }

  @override
  void onClose() {
    _cancelTimers();
    super.onClose();
  }
}
