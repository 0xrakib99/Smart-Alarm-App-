import 'package:smart_alarm/data/models/alarm_history_record.dart';

class StreakResult {
  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDays,
  });

  final int currentStreak;
  final int longestStreak;
  final Set<DateTime> completedDays;

  static const StreakResult empty = StreakResult(
    currentStreak: 0,
    longestStreak: 0,
    completedDays: <DateTime>{},
  );
}

abstract final class StreakCalculator {
  /// Normalizes a [DateTime] to calendar date (midnight, local).
  static DateTime normalizeDate(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Calculates the wake-up streaks from a list of [AlarmHistoryRecord]s.
  ///
  /// - Only records with [AlarmHistoryStatus.completed] count as successful days.
  /// - Multiple completions on the same calendar day count as 1 day.
  /// - If [referenceDate] is not provided, [DateTime.now()] is used.
  static StreakResult calculate(
    List<AlarmHistoryRecord> records, {
    DateTime? referenceDate,
  }) {
    if (records.isEmpty) {
      return StreakResult.empty;
    }

    final today = normalizeDate(referenceDate ?? DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Extract all unique dates with completed alarms
    final completedDays = <DateTime>{};
    for (final record in records) {
      if (record.status == AlarmHistoryStatus.completed) {
        completedDays.add(normalizeDate(record.actualTime));
      }
    }

    if (completedDays.isEmpty) {
      return StreakResult.empty;
    }

    // Sort dates ascending
    final sortedDays = completedDays.toList()..sort();

    // 1. Calculate Longest Streak
    int longest = 0;
    int currentRunning = 0;
    DateTime? prev;

    for (final day in sortedDays) {
      if (prev == null) {
        currentRunning = 1;
      } else {
        final diff = day.difference(prev).inDays;
        if (diff == 1) {
          currentRunning++;
        } else if (diff > 1) {
          currentRunning = 1;
        }
      }
      if (currentRunning > longest) {
        longest = currentRunning;
      }
      prev = day;
    }

    // 2. Calculate Current Streak
    // The current streak is valid if the most recent completed day is today OR yesterday.
    int current = 0;
    DateTime checkDay;

    if (completedDays.contains(today)) {
      checkDay = today;
    } else if (completedDays.contains(yesterday)) {
      checkDay = yesterday;
    } else {
      // Neither today nor yesterday had a completion, so current streak is 0.
      return StreakResult(
        currentStreak: 0,
        longestStreak: longest,
        completedDays: completedDays,
      );
    }

    while (completedDays.contains(checkDay)) {
      current++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return StreakResult(
      currentStreak: current,
      longestStreak: longest,
      completedDays: completedDays,
    );
  }
}
