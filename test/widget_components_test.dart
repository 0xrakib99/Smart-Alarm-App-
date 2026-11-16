import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/core/widgets/weekday_selector.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/presentation/widgets/mission_card.dart';
import 'package:smart_alarm/features/settings/presentation/widgets/theme_mode_selector.dart';

void main() {
  testWidgets('theme selector exposes all appearance choices', (tester) async {
    ThemePreference? changed;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ThemeModeSelector(
                selected: ThemePreference.light,
                onChanged: (value) => changed = value,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(changed, ThemePreference.dark);
  });

  testWidgets('weekday selector reports the tapped day', (tester) async {
    int? toggledDay;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: WeekdaySelector(
              selectedDays: const <int>{1},
              onDayToggled: (day) => toggledDay = day,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('W'));
    await tester.pumpAndSettle();

    expect(toggledDay, DateTime.wednesday);
  });

  testWidgets('selected mission card stays usable on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    MissionDifficulty selectedDifficulty = MissionDifficulty.easy;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: MissionCard(
              type: MissionType.math,
              selected: true,
              difficulty: selectedDifficulty,
              onSelect: () {},
              onDifficultyChanged: (value) => selectedDifficulty = value,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Math Challenge'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();

    expect(selectedDifficulty, MissionDifficulty.hard);
    expect(tester.takeException(), isNull);
  });
}
