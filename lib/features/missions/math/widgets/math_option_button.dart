import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class MathOptionButton extends StatelessWidget {
  const MathOptionButton({
    super.key,
    required this.value,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
    this.disabled = false,
  });

  final int value;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor = colorScheme.surface;
    Color borderColor = colorScheme.outlineVariant;
    Color textColor = colorScheme.onSurface;

    if (isSelected) {
      if (isCorrect == true) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
      } else if (isCorrect == false) {
        backgroundColor = colorScheme.error.withValues(alpha: 0.1);
        borderColor = colorScheme.error;
        textColor = colorScheme.error;
      } else {
        backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
        borderColor = colorScheme.primary;
        textColor = colorScheme.primary;
      }
    }

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Text(
          '$value',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
