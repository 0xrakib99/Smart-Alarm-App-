import 'package:flutter/material.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/features/statistics/domain/statistics_summary.dart';
import 'package:smart_alarm/features/statistics/domain/streak_calculator.dart';

abstract final class StatisticsCalculator {
  static StatisticsSummary calculate(
    List<AlarmHistoryRecord> records, {
    DateTime? referenceDate,
  }) {
    if (records.isEmpty) {
      return StatisticsSummary.empty;
    }

    final now = referenceDate ?? DateTime.now();

    int completed = 0;
    int missed = 0;
    int snoozed = 0;
    int cancelled = 0;
    int totalSnoozeActions = 0;

    int totalDurationSeconds = 0;
    int durationRecordsCount = 0;

    int totalWakeUpMinutes = 0;
    int wakeUpTimeCount = 0;

    final missionCounts = <String, int>{};
    final completedRecords = <AlarmHistoryRecord>[];

    for (final record in records) {
      totalSnoozeActions += record.snoozeCount;

      switch (record.status) {
        case AlarmHistoryStatus.completed:
          completed++;
          completedRecords.add(record);
          if (record.durationSeconds > 0) {
            totalDurationSeconds += record.durationSeconds;
            durationRecordsCount++;
          }
          final minutes =
              record.actualTime.hour * 60 + record.actualTime.minute;
          totalWakeUpMinutes += minutes;
          wakeUpTimeCount++;

          for (final mission in record.completedMissions) {
            final key = mission.toLowerCase();
            missionCounts[key] = (missionCounts[key] ?? 0) + 1;
          }
          break;
        case AlarmHistoryStatus.missed:
          missed++;
          break;
        case AlarmHistoryStatus.snoozed:
          snoozed++;
          break;
        case AlarmHistoryStatus.cancelled:
          cancelled++;
          break;
      }
    }

    // 1. Streak
    final streakResult = StreakCalculator.calculate(
      records,
      referenceDate: now,
    );

    // 2. Average Wake-up Time
    TimeOfDay? avgWakeUpTime;
    if (wakeUpTimeCount > 0) {
      final avgMinutes = totalWakeUpMinutes ~/ wakeUpTimeCount;
      avgWakeUpTime = TimeOfDay(
        hour: (avgMinutes ~/ 60) % 24,
        minute: avgMinutes % 60,
      );
    }

    // 3. Average Mission Duration
    final avgDuration = durationRecordsCount > 0
        ? totalDurationSeconds ~/ durationRecordsCount
        : 0;

    // 4. Weekly and Monthly Rates
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    int weekCompleted = 0;
    int weekTotal = 0;
    int monthCompleted = 0;
    int monthTotal = 0;

    for (final r in records) {
      if (r.actualTime.isAfter(sevenDaysAgo)) {
        if (r.status == AlarmHistoryStatus.completed) {
          weekCompleted++;
          weekTotal++;
        } else if (r.status == AlarmHistoryStatus.missed ||
            r.status == AlarmHistoryStatus.cancelled) {
          weekTotal++;
        }
      }

      if (r.actualTime.isAfter(thirtyDaysAgo)) {
        if (r.status == AlarmHistoryStatus.completed) {
          monthCompleted++;
          monthTotal++;
        } else if (r.status == AlarmHistoryStatus.missed ||
            r.status == AlarmHistoryStatus.cancelled) {
          monthTotal++;
        }
      }
    }

    final weeklyRate = weekTotal > 0 ? (weekCompleted / weekTotal) : 0.0;
    final monthlyRate = monthTotal > 0 ? (monthCompleted / monthTotal) : 0.0;

    // 5. Weekly Activity (Past 7 calendar days)
    final weeklyActivity = <DayActivity>[];
    for (int i = 6; i >= 0; i--) {
      final targetDate = StreakCalculator.normalizeDate(
        now.subtract(Duration(days: i)),
      );
      final isToday = i == 0;
      final weekdayLabel = AppDateUtils.weekdayShortName(targetDate.weekday);

      int dayCount = 0;
      for (final r in completedRecords) {
        if (StreakCalculator.normalizeDate(r.actualTime) == targetDate) {
          dayCount++;
        }
      }

      weeklyActivity.add(
        DayActivity(
          dayLabel: weekdayLabel,
          completedCount: dayCount,
          isToday: isToday,
        ),
      );
    }

    // 6. Insights (Derived strictly from real data)
    final insights = _generateInsights(
      completedRecords: completedRecords,
      missedCount: missed,
      avgWakeUpTime: avgWakeUpTime,
      missionCounts: missionCounts,
    );

    return StatisticsSummary(
      totalCompleted: completed,
      totalMissed: missed,
      totalSnoozed: totalSnoozeActions > 0 ? totalSnoozeActions : snoozed,
      totalCancelled: cancelled,
      currentStreak: streakResult.currentStreak,
      longestStreak: streakResult.longestStreak,
      averageWakeUpTime: avgWakeUpTime,
      averageMissionDurationSeconds: avgDuration,
      weeklyCompletionRate: weeklyRate,
      monthlyCompletionRate: monthlyRate,
      weeklyActivity: weeklyActivity,
      missionTypeCounts: missionCounts,
      insights: insights,
    );
  }

  static List<InsightItem> _generateInsights({
    required List<AlarmHistoryRecord> completedRecords,
    required int missedCount,
    required TimeOfDay? avgWakeUpTime,
    required Map<String, int> missionCounts,
  }) {
    final list = <InsightItem>[];

    if (completedRecords.length < 2) {
      return list;
    }

    // Insight 1: Most consistent weekday
    final weekdayTally = <int, int>{};
    for (final r in completedRecords) {
      final w = r.actualTime.weekday;
      weekdayTally[w] = (weekdayTally[w] ?? 0) + 1;
    }

    if (weekdayTally.isNotEmpty) {
      final bestWeekdayEntry = weekdayTally.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final bestDayName = _weekdayFullName(bestWeekdayEntry.key);
      list.add(
        InsightItem(
          title: 'Most Consistent Day',
          description:
              'You wake up most reliably on $bestDayName (${bestWeekdayEntry.value} alarms completed).',
          icon: Icons.calendar_today_rounded,
        ),
      );
    }

    // Insight 2: Average wake-up time
    if (avgWakeUpTime != null) {
      final formattedTime = AppDateUtils.formatTime(
        avgWakeUpTime.hour,
        avgWakeUpTime.minute,
      );
      list.add(
        InsightItem(
          title: 'Average Wake-up Time',
          description: 'Your average wake-up time is $formattedTime.',
          icon: Icons.access_time_rounded,
        ),
      );
    }

    // Insight 3: Preferred Mission
    if (missionCounts.isNotEmpty) {
      final topMission = missionCounts.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final missionName = _capitalize(topMission.key);
      list.add(
        InsightItem(
          title: 'Favorite Challenge',
          description:
              '$missionName mission completed ${topMission.value} times.',
          icon: Icons.military_tech_rounded,
        ),
      );
    }

    // Insight 4: Discipline & Snooze
    if (missedCount == 0 && completedRecords.length >= 3) {
      list.add(
        const InsightItem(
          title: 'High Reliability',
          description: 'Zero alarms missed so far. Excellent consistency!',
          icon: Icons.verified_rounded,
        ),
      );
    }

    return list;
  }

  static String _weekdayFullName(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => 'Day',
    };
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
