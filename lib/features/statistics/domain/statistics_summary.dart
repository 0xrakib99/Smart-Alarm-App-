import 'package:flutter/material.dart';

class InsightItem {
  const InsightItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class DayActivity {
  const DayActivity({
    required this.dayLabel,
    required this.completedCount,
    required this.isToday,
  });

  final String dayLabel;
  final int completedCount;
  final bool isToday;
}

class StatisticsSummary {
  const StatisticsSummary({
    required this.totalCompleted,
    required this.totalMissed,
    required this.totalSnoozed,
    required this.totalCancelled,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageWakeUpTime,
    required this.averageMissionDurationSeconds,
    required this.weeklyCompletionRate,
    required this.monthlyCompletionRate,
    required this.weeklyActivity,
    required this.missionTypeCounts,
    required this.insights,
  });

  final int totalCompleted;
  final int totalMissed;
  final int totalSnoozed;
  final int totalCancelled;
  final int currentStreak;
  final int longestStreak;
  final TimeOfDay? averageWakeUpTime;
  final int averageMissionDurationSeconds;
  final double weeklyCompletionRate;
  final double monthlyCompletionRate;
  final List<DayActivity> weeklyActivity;
  final Map<String, int> missionTypeCounts;
  final List<InsightItem> insights;

  int get totalLogged => totalCompleted + totalMissed + totalCancelled;

  bool get hasSufficientData => totalCompleted > 0 || totalLogged > 0;

  static const StatisticsSummary empty = StatisticsSummary(
    totalCompleted: 0,
    totalMissed: 0,
    totalSnoozed: 0,
    totalCancelled: 0,
    currentStreak: 0,
    longestStreak: 0,
    averageWakeUpTime: null,
    averageMissionDurationSeconds: 0,
    weeklyCompletionRate: 0.0,
    monthlyCompletionRate: 0.0,
    weeklyActivity: <DayActivity>[],
    missionTypeCounts: <String, int>{},
    insights: <InsightItem>[],
  );
}
