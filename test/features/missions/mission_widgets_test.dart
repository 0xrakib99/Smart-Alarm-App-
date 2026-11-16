import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/math/controllers/math_mission_controller.dart';
import 'package:smart_alarm/features/missions/math/screens/math_mission_screen.dart';
import 'package:smart_alarm/features/missions/memory/controllers/memory_mission_controller.dart';
import 'package:smart_alarm/features/missions/memory/screens/memory_mission_screen.dart';
import 'package:smart_alarm/features/missions/puzzle/controllers/puzzle_mission_controller.dart';
import 'package:smart_alarm/features/missions/puzzle/screens/puzzle_mission_screen.dart';
import 'package:smart_alarm/features/missions/shake/controllers/shake_mission_controller.dart';
import 'package:smart_alarm/features/missions/shake/screens/shake_mission_screen.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/tap/controllers/tap_mission_controller.dart';
import 'package:smart_alarm/features/missions/tap/screens/tap_mission_screen.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('MathMissionScreen renders question and options properly', (
    tester,
  ) async {
    final controller = Get.put(
      MathMissionController(difficulty: MissionDifficulty.easy),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const MathMissionScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Math Challenge'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.onClose();
  });

  testWidgets('TapMissionScreen renders target properly', (tester) async {
    final controller = Get.put(
      TapMissionController(difficulty: MissionDifficulty.easy),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const TapMissionScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tap Challenge'), findsOneWidget);
    expect(find.bySemanticsLabel('Reaction target'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.onClose();
  });

  testWidgets('MemoryMissionScreen renders card grid', (tester) async {
    final controller = Get.put(
      MemoryMissionController(difficulty: MissionDifficulty.easy),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const MemoryMissionScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Memory Match'), findsOneWidget);
    expect(find.bySemanticsLabel('Card face down'), findsNWidgets(4));
    expect(tester.takeException(), isNull);

    controller.onClose();
  });

  testWidgets('PuzzleMissionScreen renders sliding puzzle board', (
    tester,
  ) async {
    final controller = Get.put(
      PuzzleMissionController(difficulty: MissionDifficulty.easy),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const PuzzleMissionScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Number Puzzle'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.onClose();
  });

  testWidgets('ShakeMissionScreen renders gauge and instruction', (
    tester,
  ) async {
    final controller = Get.put(
      ShakeMissionController(
        difficulty: MissionDifficulty.easy,
        autoStartDetector: false,
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const ShakeMissionScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shake Challenge'), findsOneWidget);
    expect(find.text('Shake your phone'), findsOneWidget);
    expect(tester.takeException(), isNull);

    controller.onClose();
  });

  testWidgets('MissionCompletionScreen displays summary statistics correctly', (
    tester,
  ) async {
    final started = DateTime(2026, 11, 12, 10, 0, 0);
    final completed = DateTime(2026, 11, 12, 10, 0, 25);
    final result = MissionResult(
      type: MissionType.math,
      difficulty: MissionDifficulty.medium,
      isSuccess: true,
      startedAt: started,
      completedAt: completed,
      moves: 5,
      attempts: 6,
      metrics: const <String, dynamic>{'Accuracy': '100%'},
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        home: MissionCompletionScreen(result: result),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mission completed'), findsOneWidget);
    expect(find.text('Time elapsed'), findsOneWidget);
    expect(find.text('25s'), findsOneWidget);
    expect(find.text('Moves'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Complete mission'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
