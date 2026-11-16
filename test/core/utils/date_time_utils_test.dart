import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';

void main() {
  final now = DateTime(2026, 11, 12, 6, 30);

  group('AppDateUtils formatting', () {
    test('formats a full date', () {
      expect(AppDateUtils.formatFullDate(now), 'Thursday, 12 November');
    });

    test('formats 12-hour clock values', () {
      expect(AppDateUtils.formatTime(7, 5), '7:05 AM');
      expect(AppDateUtils.formatTime(0, 0), '12:00 AM');
      expect(AppDateUtils.formatTime(13, 7), '1:07 PM');
      expect(AppDateUtils.formatTimeWithoutPeriod(21, 45), '9:45');
      expect(AppDateUtils.period(12), 'PM');
    });

    test('summarizes repeat days', () {
      expect(AppDateUtils.daysSummary(const <int>[]), 'Once');
      expect(
        AppDateUtils.daysSummary(const <int>[1, 2, 3, 4, 5, 6, 7]),
        'Every day',
      );
      expect(AppDateUtils.daysSummary(const <int>[1, 2, 3, 4, 5]), 'Weekdays');
      expect(AppDateUtils.daysSummary(const <int>[6, 7]), 'Weekends');
      expect(AppDateUtils.daysSummary(const <int>[5, 1, 3]), 'Mon, Wed, Fri');
    });

    test('labels the next day relative to today', () {
      expect(AppDateUtils.dayLabel(DateTime(2026, 11, 12, 7), now), 'Today');
      expect(AppDateUtils.dayLabel(DateTime(2026, 11, 13, 7), now), 'Tomorrow');
      expect(AppDateUtils.dayLabel(DateTime(2026, 11, 16, 7), now), 'Monday');
      expect(AppDateUtils.dayLabel(DateTime(2026, 11, 25, 7), now), '25 Nov');
    });
  });

  group('AppDateUtils.nextOccurrence', () {
    test('returns today when the alarm is still ahead', () {
      final alarm = _alarm(hour: 7, repeatDays: const <int>[4]);

      expect(
        AppDateUtils.nextOccurrence(alarm, now),
        DateTime(2026, 11, 12, 7),
      );
    });

    test('returns next week when the alarm time already passed', () {
      final alarm = _alarm(hour: 6, repeatDays: const <int>[4]);

      expect(
        AppDateUtils.nextOccurrence(alarm, now),
        DateTime(2026, 11, 19, 6),
      );
    });

    test('uses tomorrow for a one-time alarm that already passed', () {
      final alarm = _alarm(hour: 6);

      expect(
        AppDateUtils.nextOccurrence(alarm, now),
        DateTime(2026, 11, 13, 6),
      );
    });

    test('returns null for a disabled alarm', () {
      final alarm = _alarm(hour: 7, enabled: false, repeatDays: const <int>[4]);

      expect(AppDateUtils.nextOccurrence(alarm, now), isNull);
    });
  });
}

AlarmModel _alarm({
  required int hour,
  int minute = 0,
  List<int> repeatDays = const <int>[],
  bool enabled = true,
}) {
  return AlarmModel(
    id: 'test_alarm',
    hour: hour,
    minute: minute,
    label: 'Test alarm',
    repeatDays: repeatDays,
    soundId: 'default',
    vibrationEnabled: true,
    snoozeEnabled: true,
    snoozeMinutes: 5,
    enabled: enabled,
    createdAt: DateTime(2026, 11, 1),
  );
}
