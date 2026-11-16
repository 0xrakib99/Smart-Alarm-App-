import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_empty_state.dart';
import 'package:smart_alarm/core/widgets/app_section_header.dart';
import 'package:smart_alarm/features/statistics/controllers/statistics_controller.dart';
import 'package:smart_alarm/features/statistics/domain/statistics_summary.dart';

class StatisticsScreen extends GetView<StatisticsController> {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & Analytics'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: controller.reloadStatistics,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.pageMaxWidth,
            ),
            child: Obx(() {
              final summary = controller.summary.value;

              if (!summary.hasSufficientData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.horizontalPadding),
                    child: AppCard(
                      child: AppEmptyState(
                        icon: Icons.insights_rounded,
                        title: 'No statistics yet',
                        message:
                            'Complete your scheduled alarms and missions to track streaks, wake-up times, and weekly consistency.',
                      ),
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  8,
                  AppConstants.horizontalPadding,
                  32,
                ),
                children: <Widget>[
                  // 1. Streak Card
                  _StreakCard(summary: summary),
                  const SizedBox(height: 20),

                  // 2. Metrics Grid
                  const AppSectionHeader(title: 'Overview'),
                  const SizedBox(height: 10),
                  _MetricsGrid(summary: summary),
                  const SizedBox(height: 24),

                  // 3. Weekly Activity Chart
                  const AppSectionHeader(title: 'Weekly wake-up activity'),
                  const SizedBox(height: 10),
                  _WeeklyActivityChart(activities: summary.weeklyActivity),
                  const SizedBox(height: 24),

                  // 4. Mission Breakdown
                  if (summary.missionTypeCounts.isNotEmpty) ...<Widget>[
                    const AppSectionHeader(
                      title: 'Mission challenge breakdown',
                    ),
                    const SizedBox(height: 10),
                    _MissionBreakdownCard(
                      missionCounts: summary.missionTypeCounts,
                      totalCompleted: summary.totalCompleted,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 5. Insights
                  if (summary.insights.isNotEmpty) ...<Widget>[
                    const AppSectionHeader(title: 'Wake-up insights'),
                    const SizedBox(height: 10),
                    _InsightsCard(insights: summary.insights),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      backgroundColor: colorScheme.primary,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 28,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CURRENT STREAK',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      '${summary.currentStreak}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      summary.currentStreak == 1 ? 'day' : 'days',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.emoji_events_outlined,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Best: ${summary.longestStreak} d',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});

  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final wakeTimeStr = summary.averageWakeUpTime != null
        ? AppDateUtils.formatTime(
            summary.averageWakeUpTime!.hour,
            summary.averageWakeUpTime!.minute,
          )
        : 'N/A';

    final weekPct = (summary.weeklyCompletionRate * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: itemWidth,
              child: _MetricTile(
                title: 'Alarms Completed',
                value: '${summary.totalCompleted}',
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricTile(
                title: 'Alarms Missed',
                value: '${summary.totalMissed}',
                icon: Icons.alarm_off_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricTile(
                title: 'Avg Wake-up Time',
                value: wakeTimeStr,
                icon: Icons.schedule_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricTile(
                title: '7-Day Success Rate',
                value: '$weekPct%',
                icon: Icons.trending_up_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricTile(
                title: 'Avg Mission Time',
                value: summary.averageMissionDurationSeconds > 0
                    ? '${summary.averageMissionDurationSeconds}s'
                    : 'N/A',
                icon: Icons.timer_outlined,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _MetricTile(
                title: 'Total Snoozes',
                value: '${summary.totalSnoozed}',
                icon: Icons.snooze_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart({required this.activities});

  final List<DayActivity> activities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int maxCount = 1;
    for (final a in activities) {
      if (a.completedCount > maxCount) maxCount = a.completedCount;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Past 7 days completed alarms',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: activities
                .map((day) {
                  final ratio = (day.completedCount / maxCount).clamp(
                    0.08,
                    1.0,
                  );
                  final barHeight = 80.0 * ratio;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        day.completedCount > 0 ? '${day.completedCount}' : '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: day.isToday
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 22,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: day.completedCount > 0
                              ? (day.isToday
                                    ? colorScheme.primary
                                    : colorScheme.primary.withValues(
                                        alpha: 0.45,
                                      ))
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.dayLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: day.isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: day.isToday
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _MissionBreakdownCard extends StatelessWidget {
  const _MissionBreakdownCard({
    required this.missionCounts,
    required this.totalCompleted,
  });

  final Map<String, int> missionCounts;
  final int totalCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: missionCounts.entries
            .map((entry) {
              final count = entry.value;
              final pct = totalCompleted > 0 ? (count / totalCompleted) : 0.0;
              final missionTitle = entry.key.toUpperCase();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          missionTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$count completed (${(pct * 100).round()}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.insights});

  final List<InsightItem> insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: insights
            .map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
