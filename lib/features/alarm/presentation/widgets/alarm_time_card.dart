import 'package:flutter/material.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';

class AlarmTimeCard extends StatelessWidget {
  const AlarmTimeCard({
    super.key,
    required this.hour,
    required this.minute,
    required this.onTap,
  });

  final int hour;
  final int minute;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'ALARM TIME',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: AppDateUtils.formatTimeWithoutPeriod(hour, minute),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 58,
                        height: 1.05,
                      ),
                    ),
                    TextSpan(
                      text: ' ${AppDateUtils.period(hour)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                key: ValueKey<String>('$hour:$minute'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.edit_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Tap to change',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
