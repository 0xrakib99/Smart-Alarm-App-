import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          disabledBackgroundColor: isLoading ? colorScheme.primary : null,
          disabledForegroundColor: isLoading ? colorScheme.onPrimary : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Row(
            key: ValueKey<bool>(isLoading),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 20),
              if (isLoading || icon != null) const SizedBox(width: 10),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
