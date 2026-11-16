import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/home/controllers/home_controller.dart';

class NextAlarmCard extends StatelessWidget {
  const NextAlarmCard({
    super.key,
    required this.nextAlarm,
    required this.now,
    required this.hasAlarms,
    this.onTap,
  });

  final NextAlarmInfo? nextAlarm;
  final DateTime now;
  final bool hasAlarms;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final info = nextAlarm;
    if (info == null) {
      return _EmptyNextAlarmCard(hasAlarms: hasAlarms);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final alarm = info.alarm;
    final label = alarm.label.trim().isEmpty
        ? AppConstants.defaultAlarmLabel
        : alarm.label;
    final missionText = alarm.missions.isEmpty
        ? 'No mission'
        : alarm.missions.length == 1
        ? '${alarm.missions.first.type.label} · ${alarm.missions.first.difficulty.label}'
        : '${alarm.missions.length} missions';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.onPrimary.withValues(alpha: 0.08),
          highlightColor: colorScheme.onPrimary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'NEXT ALARM',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.72),
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallRadius,
                        ),
                      ),
                      child: Text(
                        AppDateUtils.dayLabel(info.occursAt, now),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppDateUtils.formatTime(alarm.hour, alarm.minute),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: <Widget>[
                    _NextAlarmMeta(
                      icon: Icons.repeat_rounded,
                      text: AppDateUtils.daysSummary(alarm.repeatDays),
                    ),
                    _NextAlarmMeta(icon: Icons.bolt_rounded, text: missionText),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NextAlarmMeta extends StatelessWidget {
  const _NextAlarmMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimary.withValues(alpha: 0.72);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

class _EmptyNextAlarmCard extends StatelessWidget {
  const _EmptyNextAlarmCard({required this.hasAlarms});

  final bool hasAlarms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
            child: Icon(
              Icons.alarm_off_rounded,
              size: 22,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasAlarms ? 'No upcoming alarm' : 'No alarms scheduled',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  hasAlarms
                      ? 'Every alarm is turned off. Turn one on to see your '
                            'next wake-up.'
                      : 'Create an alarm to see your next wake-up here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
