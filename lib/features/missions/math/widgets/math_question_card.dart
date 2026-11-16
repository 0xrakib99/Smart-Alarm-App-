import 'package:flutter/material.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';

class MathQuestionCard extends StatelessWidget {
  const MathQuestionCard({super.key, required this.expression});

  final String expression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Calculate',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            expression,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
