import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.isMovable,
    required this.onTap,
  });

  final int value;
  final bool isMovable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      enabled: isMovable,
      label: 'Tile $value',
      child: InkWell(
        onTap: isMovable ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isMovable
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            border: Border.all(
              color: isMovable
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isMovable ? 2 : 1,
            ),
          ),
          child: Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isMovable ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
