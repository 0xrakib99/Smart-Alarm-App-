import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class MissionProgress extends StatelessWidget {
  const MissionProgress({
    super.key,
    required this.current,
    required this.total,
    this.label,
    this.secondaryText,
  });

  final int current;
  final int total;
  final String? label;
  final String? secondaryText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label ?? '$current of $total',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (secondaryText != null)
              Text(
                secondaryText!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
