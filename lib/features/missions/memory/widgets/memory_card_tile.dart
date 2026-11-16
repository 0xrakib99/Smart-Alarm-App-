import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/missions/memory/models/memory_card_item.dart';

class MemoryCardTile extends StatelessWidget {
  const MemoryCardTile({super.key, required this.card, required this.onTap});

  final MemoryCardItem card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final isFaceUp = card.isFaceUp.value;
      final isMatched = card.isMatched.value;

      Color backgroundColor = colorScheme.surfaceContainer;
      Color borderColor = colorScheme.outlineVariant;

      if (isMatched) {
        backgroundColor = colorScheme.primary.withValues(alpha: 0.12);
        borderColor = colorScheme.primary.withValues(alpha: 0.35);
      } else if (isFaceUp) {
        backgroundColor = colorScheme.surface;
        borderColor = colorScheme.primary;
      }

      return Semantics(
        button: true,
        label: isFaceUp ? 'Card face up' : 'Card face down',
        child: InkWell(
          onTap: (isFaceUp || isMatched) ? null : onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              border: Border.all(
                color: borderColor,
                width: isFaceUp || isMatched ? 2 : 1,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isFaceUp || isMatched
                    ? Icon(
                        card.icon,
                        key: ValueKey<int>(card.pairId),
                        size: 34,
                        color: isMatched
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      )
                    : Icon(
                        Icons.help_outline_rounded,
                        key: const ValueKey<String>('back'),
                        size: 26,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
