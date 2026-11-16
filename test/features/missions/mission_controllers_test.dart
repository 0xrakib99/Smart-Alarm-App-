import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/math/controllers/math_mission_controller.dart';
import 'package:smart_alarm/features/missions/memory/controllers/memory_mission_controller.dart';
import 'package:smart_alarm/features/missions/puzzle/controllers/puzzle_mission_controller.dart';
import 'package:smart_alarm/features/missions/shake/controllers/shake_mission_controller.dart';
import 'package:smart_alarm/features/missions/tap/controllers/tap_mission_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MathMissionController', () {
    test(
      'initializes with correct question count and generates first problem',
      () {
        final controller = MathMissionController(
          difficulty: MissionDifficulty.easy,
        );
        controller.onInit();

        expect(controller.totalQuestions, 3);
        expect(controller.currentIndex.value, 0);
        expect(controller.status.value, MissionStatus.inProgress);
        expect(controller.currentProblem.value, isNotNull);

        controller.onClose();
      },
    );

    test('selectAnswer handles wrong answer without crashing', () {
      final controller = MathMissionController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      final problem = controller.currentProblem.value!;
      final wrongOption = problem.options.firstWhere(
        (opt) => opt != problem.correctAnswer,
      );

      controller.selectAnswer(wrongOption);
      expect(controller.totalAttempts, 1);
      expect(controller.lastAnswerCorrect.value, isFalse);

      controller.onClose();
    });
  });

  group('TapMissionController', () {
    test('tracks taps and detects completion', () {
      final controller = TapMissionController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      expect(controller.targetCount, 10);
      expect(controller.successfulTaps.value, 0);

      // Tap targets until completion
      for (int i = 0; i < 10; i++) {
        controller.onTapTarget();
      }

      expect(controller.status.value, MissionStatus.completed);
      expect(controller.result.value, isNotNull);
      expect(controller.result.value!.isSuccess, isTrue);

      controller.onClose();
    });
  });

  group('MemoryMissionController', () {
    test('initializes card pairs correctly', () {
      final controller = MemoryMissionController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      expect(controller.totalPairs, 2);
      expect(controller.cards.length, 4); // 2 pairs = 4 cards
      expect(controller.status.value, MissionStatus.inProgress);

      controller.onClose();
    });
  });

  group('PuzzleMissionController', () {
    test('initializes solvable board with correct grid size', () {
      final controller = PuzzleMissionController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      expect(controller.gridSize, 3);
      expect(controller.tiles.length, 9);
      expect(controller.tiles.contains(0), isTrue);
      expect(controller.status.value, MissionStatus.inProgress);

      controller.onClose();
    });
  });

  group('ShakeMissionController', () {
    test('tracks manual shake and reaches completion', () {
      final controller = ShakeMissionController(
        difficulty: MissionDifficulty.easy,
        autoStartDetector: false,
      );
      controller.onInit();

      expect(controller.requiredShakes, 20);
      expect(controller.currentShakes.value, 0);

      for (int i = 0; i < 20; i++) {
        controller.manualShake();
      }

      expect(controller.status.value, MissionStatus.completed);
      expect(controller.result.value, isNotNull);
      expect(controller.result.value!.moves, 20);

      controller.onClose();
    });
  });
}
