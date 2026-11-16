import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/features/statistics/domain/statistics_calculator.dart';

void main() {
  group('StatisticsCalculator', () {
    final now = DateTime(2026, 5, 10, 8, 0); // Reference time

    test('returns empty summary when records are empty', () {
      final summary = StatisticsCalculator.calculate(
        <AlarmHistoryRecord>[],
        referenceDate: now,
      );
      expect(summary.totalCompleted, 0);
      expect(summary.totalMissed, 0);
      expect(summary.hasSufficientData, isFalse);
    });

    test('correctly aggregates counts, duration, and average wake-up time', () {
      final records = <AlarmHistoryRecord>[
        AlarmHistoryRecord(
          id: '1',
          alarmId: 'a1',
          alarmLabel: 'Morning 1',
          scheduledTime: DateTime(2026, 5, 9, 7, 0),
          actualTime: DateTime(2026, 5, 9, 7, 0),
          status: AlarmHistoryStatus.completed,
          completedMissions: const <String>['math'],
          durationSeconds: 20,
          snoozeCount: 1,
        ),
        AlarmHistoryRecord(
          id: '2',
          alarmId: 'a1',
          alarmLabel: 'Morning 2',
          scheduledTime: DateTime(2026, 5, 10, 7, 30),
          actualTime: DateTime(2026, 5, 10, 7, 30),
          status: AlarmHistoryStatus.completed,
          completedMissions: const <String>['math'],
          durationSeconds: 40,
          snoozeCount: 0,
        ),
        AlarmHistoryRecord(
          id: '3',
          alarmId: 'a2',
          alarmLabel: 'Missed Alarm',
          scheduledTime: DateTime(2026, 5, 8, 6, 0),
          actualTime: DateTime(2026, 5, 8, 6, 0),
          status: AlarmHistoryStatus.missed,
        ),
      ];

      final summary = StatisticsCalculator.calculate(
        records,
        referenceDate: now,
      );

      expect(summary.totalCompleted, 2);
      expect(summary.totalMissed, 1);
      expect(summary.totalSnoozed, 1);
      // Average duration: (20 + 40) / 2 = 30 seconds
      expect(summary.averageMissionDurationSeconds, 30);
      // Average wake up time: (7:00 + 7:30) / 2 = 7:15
      expect(summary.averageWakeUpTime?.hour, 7);
      expect(summary.averageWakeUpTime?.minute, 15);
      // Weekly completion rate: 2 completed out of 3 total = 2/3 ~ 0.67
      expect(summary.weeklyCompletionRate, closeTo(0.66, 0.02));
      // Mission counts
      expect(summary.missionTypeCounts['math'], 2);
      // Weekly activity has 7 items
      expect(summary.weeklyActivity.length, 7);
      // Insights generated
      expect(summary.insights, isNotEmpty);
    });
  });
}
