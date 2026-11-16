import 'package:flutter/material.dart';

class ShakeProgressGauge extends StatelessWidget {
  const ShakeProgressGauge({
    super.key,
    required this.current,
    required this.total,
    this.intensity = 0.0,
  });

  final int current;
  final int total;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.vibration_rounded,
                size: 38,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                '$current',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'of $total shakes',
                style: theme.textTheme.bodyMedium?.copyWith(
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
