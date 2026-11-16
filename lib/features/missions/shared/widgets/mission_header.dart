import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/data/models/mission_config.dart';

class MissionHeader extends StatelessWidget implements PreferredSizeWidget {
  const MissionHeader({
    super.key,
    required this.title,
    required this.difficulty,
    this.onExitPressed,
    this.actions,
  });

  final String title;
  final MissionDifficulty difficulty;
  final VoidCallback? onExitPressed;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Exit mission',
        onPressed: onExitPressed ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(title),
      centerTitle: false,
      actions: <Widget>[
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              difficulty.label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        ...?actions,
      ],
    );
  }
}
