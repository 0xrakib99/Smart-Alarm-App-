import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/features/statistics/domain/streak_calculator.dart';

void main() {
  group('StreakCalculator', () {
    final now = DateTime(2026, 5, 10, 8, 30); // Sunday

    test('returns empty result when records list is empty', () {
      final result = StreakCalculator.calculate(
        <AlarmHistoryRecord>[],
        referenceDate: now,
      );
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.completedDays, isEmpty);
    });

    test('calculates streak for single completion today', () {
      final records = <AlarmHistoryRecord>[
        AlarmHistoryRecord(
          id: '1',
          alarmId: 'a1',
          alarmLabel: 'Test',
          scheduledTime: now,
          actualTime: now,
          status: AlarmHistoryStatus.completed,
        ),
      ];

      final result = StreakCalculator.calculate(records, referenceDate: now);
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.completedDays.length, 1);
    });

    test('multiple completions on same day count as single streak day', () {
      final records = <AlarmHistoryRecord>[
        AlarmHistoryRecord(
          id: '1',
          alarmId: 'a1',
          alarmLabel: 'Morning Alarm',
          scheduledTime: now,
          actualTime: now,
          status: AlarmHistoryStatus.completed,
        ),
        AlarmHistoryRecord(
          id: '2',
          alarmId: 'a2',
          alarmLabel: 'Afternoon Reminder',
          scheduledTime: now.add(const Duration(hours: 4)),
          actualTime: now.add(const Duration(hours: 4)),
          status: AlarmHistoryStatus.completed,
        ),
      ];

      final result = StreakCalculator.calculate(records, referenceDate: now);
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.completedDays.length, 1);
    });

    test('calculates consecutive 3-day streak correctly', () {
      final records = <AlarmHistoryRecord>[
        AlarmHistoryRecord(
          id: '1',
          alarmId: 'a1',
          alarmLabel: 'Test',
          scheduledTime: now.subtract(const Duration(days: 2)),
          actualTime: now.subtract(const Duration(days: 2)),
          status: AlarmHistoryStatus.completed,
        ),
        AlarmHistoryRecord(
          id: '2',
          alarmId: 'a2',
          alarmLabel: 'Test',
          scheduledTime: now.subtract(const Duration(days: 1)),
          actualTime: now.subtract(const Duration(days: 1)),
          status: AlarmHistoryStatus.completed,
        ),
        AlarmHistoryRecord(
          id: '3',
          alarmId: 'a3',
          alarmLabel: 'Test',
          scheduledTime: now,
          actualTime: now,
          status: AlarmHistoryStatus.completed,
        ),
      ];

      final result = StreakCalculator.calculate(records, referenceDate: now);
      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test('streak breaks when there is a missing day in between', () {
      // Completed 4 days ago, 3 days ago, missed 2 days ago, completed 1 day ago and today
      final records = <AlarmHistoryRecord>[
        AlarmHistoryRecord(
          id: '1',
          alarmId: 'a1',
          alarmLabel: 'Test',
          scheduledTime: now.subtract(const Duration(days: 4)),
          actualTime: now.subtract(const Duration(days: 4)),
          status: AlarmHistoryStatus.completed,
        ),
        AlarmHistoryRecord(
          id: '2',
          alarmId: 'a2',
          alarmLabel: 'Test',
          scheduledTime: now.subtract(const Duration(days: 3)),
          actualTime: now.subtract(const Duration(days: 3)),
          status: AlarmHistoryStatus.completed,
        ),
        // Day 2 was missed
        AlarmHistoryRecord(
          id: '3',
          alarmId: 'a3',
          alarmLabel: 'Test',
          scheduledTime: now.subtract(const Duration(days: 1)),
          actualTime: now.subtract(const Duration(days: 1)),
          status: AlarmHistoryStatus.completed,
        ),
        AlarmHistoryRecord(
          id: '4',
          alarmId: 'a4',
          alarmLabel: 'Test',
          scheduledTime: now,
          actualTime: now,
          status: AlarmHistoryStatus.completed,
        ),
      ];

      final result = StreakCalculator.calculate(records, referenceDate: now);
      expect(result.currentStreak, 2); // Yesterday + Today
      expect(result.longestStreak, 2);
    });

    test('snoozed or missed alarms do not contribute to streaks', () {
      final records = <AlarmHistoryRecord>[
        AlarmHistoryRecord(
          id: '1',
          alarmId: 'a1',
          alarmLabel: 'Test',
          scheduledTime: now,
          actualTime: now,
          status: AlarmHistoryStatus.missed,
        ),
        AlarmHistoryRecord(
          id: '2',
          alarmId: 'a2',
          alarmLabel: 'Test',
          scheduledTime: now.subtract(const Duration(days: 1)),
          actualTime: now.subtract(const Duration(days: 1)),
          status: AlarmHistoryStatus.snoozed,
        ),
      ];

      final result = StreakCalculator.calculate(records, referenceDate: now);
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
    });
  });
}
