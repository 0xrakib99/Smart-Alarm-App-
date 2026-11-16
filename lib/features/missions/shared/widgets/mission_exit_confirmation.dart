import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class MissionExitConfirmation {
  static Future<bool> show(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
          ),
          title: const Text('Return to alarm?'),
          content: Text(
            'Returning to the alarm screen will resume the alarm sound. You can restart the mission anytime from the alarm screen.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep playing'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Return to alarm'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
