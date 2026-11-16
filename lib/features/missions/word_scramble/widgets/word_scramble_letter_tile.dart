import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class WordScrambleLetterTile extends StatelessWidget {
  const WordScrambleLetterTile({
    super.key,
    required this.letter,
    required this.onTap,
    this.isSelected = false,
    this.size = 52.0,
  });

  final String letter;
  final VoidCallback? onTap;
  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Letter $letter',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : (isDark
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surfaceContainer),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              letter,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
