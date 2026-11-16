import 'package:flutter/material.dart';

abstract final class AppFeedback {
  static void success(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, isError: true);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(
            children: <Widget>[
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                size: 20,
                color: colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}
