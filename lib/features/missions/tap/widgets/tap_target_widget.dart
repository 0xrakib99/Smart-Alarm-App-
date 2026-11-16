import 'package:flutter/material.dart';

class TapTargetWidget extends StatelessWidget {
  const TapTargetWidget({super.key, required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: 'Reaction target',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onTap(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
              ),
              child: Center(
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
