import 'package:flutter/material.dart';

class MissionInstruction extends StatelessWidget {
  const MissionInstruction({
    super.key,
    required this.instruction,
    this.subInstruction,
    this.icon,
  });

  final String instruction;
  final String? subInstruction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                instruction,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (subInstruction != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subInstruction!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
