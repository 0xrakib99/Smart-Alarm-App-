import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppConstants.cardRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(borderRadius);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
