import 'package:get/get.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/color_sequence/controllers/color_sequence_controller.dart';
import 'package:smart_alarm/features/missions/math/controllers/math_mission_controller.dart';
import 'package:smart_alarm/features/missions/memory/controllers/memory_mission_controller.dart';
import 'package:smart_alarm/features/missions/puzzle/controllers/puzzle_mission_controller.dart';
import 'package:smart_alarm/features/missions/shake/controllers/shake_mission_controller.dart';
import 'package:smart_alarm/features/missions/tap/controllers/tap_mission_controller.dart';
import 'package:smart_alarm/features/missions/typing/controllers/typing_mission_controller.dart';
import 'package:smart_alarm/features/missions/word_scramble/controllers/word_scramble_controller.dart';

class MathMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<MathMissionController>(
      () => MathMissionController(difficulty: difficulty),
    );
  }
}

class TapMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<TapMissionController>(
      () => TapMissionController(difficulty: difficulty),
    );
  }
}

class MemoryMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<MemoryMissionController>(
      () => MemoryMissionController(difficulty: difficulty),
    );
  }
}

class PuzzleMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<PuzzleMissionController>(
      () => PuzzleMissionController(difficulty: difficulty),
    );
  }
}

class ShakeMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<ShakeMissionController>(
      () => ShakeMissionController(difficulty: difficulty),
    );
  }
}

class WordScrambleMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<WordScrambleController>(
      () => WordScrambleController(difficulty: difficulty),
    );
  }
}

class ColorSequenceMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<ColorSequenceController>(
      () => ColorSequenceController(difficulty: difficulty),
    );
  }
}

class TypingMissionBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final difficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : MissionDifficulty.easy);

    Get.lazyPut<TypingMissionController>(
      () => TypingMissionController(difficulty: difficulty),
    );
  }
}
