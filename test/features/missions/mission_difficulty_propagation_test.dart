import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/math/controllers/math_mission_controller.dart';
import 'package:smart_alarm/features/missions/math/screens/math_mission_screen.dart';
import 'package:smart_alarm/features/missions/memory/controllers/memory_mission_controller.dart';
import 'package:smart_alarm/features/missions/memory/screens/memory_mission_screen.dart';
import 'package:smart_alarm/features/missions/puzzle/controllers/puzzle_mission_controller.dart';
import 'package:smart_alarm/features/missions/puzzle/screens/puzzle_mission_screen.dart';
import 'package:smart_alarm/features/missions/shake/controllers/shake_mission_controller.dart';
import 'package:smart_alarm/features/missions/shake/screens/shake_mission_screen.dart';
import 'package:smart_alarm/features/missions/tap/controllers/tap_mission_controller.dart';
import 'package:smart_alarm/features/missions/tap/screens/tap_mission_screen.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Mission Controllers Difficulty Argument Resolution', () {
    testWidgets(
      'MathMissionController resolves HARD difficulty from route args',
      (tester) async {
        Get.routing.args = const MissionConfig(
          type: MissionType.math,
          difficulty: MissionDifficulty.hard,
        );
        final controller = Get.put(MathMissionController());

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light,
            home: const MathMissionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.difficulty, MissionDifficulty.hard);
        expect(find.text('HARD'), findsOneWidget);
        controller.onClose();
      },
    );

    testWidgets(
      'TapMissionController resolves MEDIUM difficulty from route args',
      (tester) async {
        Get.routing.args = const MissionConfig(
          type: MissionType.tap,
          difficulty: MissionDifficulty.medium,
        );
        final controller = Get.put(TapMissionController());

        await tester.pumpWidget(
          GetMaterialApp(theme: AppTheme.light, home: const TapMissionScreen()),
        );
        await tester.pumpAndSettle();

        expect(controller.difficulty, MissionDifficulty.medium);
        expect(find.text('MEDIUM'), findsOneWidget);
        controller.onClose();
      },
    );

    testWidgets(
      'MemoryMissionController resolves HARD difficulty from route args',
      (tester) async {
        Get.routing.args = const MissionConfig(
          type: MissionType.memory,
          difficulty: MissionDifficulty.hard,
        );
        final controller = Get.put(MemoryMissionController());

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light,
            home: const MemoryMissionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.difficulty, MissionDifficulty.hard);
        expect(find.text('HARD'), findsOneWidget);
        controller.onClose();
      },
    );

    testWidgets(
      'PuzzleMissionController resolves MEDIUM difficulty from route args',
      (tester) async {
        Get.routing.args = const MissionConfig(
          type: MissionType.puzzle,
          difficulty: MissionDifficulty.medium,
        );
        final controller = Get.put(PuzzleMissionController());

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light,
            home: const PuzzleMissionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.difficulty, MissionDifficulty.medium);
        expect(controller.gridSize, 4);
        expect(find.text('MEDIUM'), findsOneWidget);
        controller.onClose();
      },
    );

    testWidgets(
      'ShakeMissionController resolves HARD difficulty from route args',
      (tester) async {
        Get.routing.args = const MissionConfig(
          type: MissionType.shake,
          difficulty: MissionDifficulty.hard,
        );
        final controller = Get.put(
          ShakeMissionController(autoStartDetector: false),
        );

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light,
            home: const ShakeMissionScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.difficulty, MissionDifficulty.hard);
        expect(find.text('HARD'), findsOneWidget);
        controller.onClose();
      },
    );
  });
}
