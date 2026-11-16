import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme create({
    required Color primaryText,
    required Color secondaryText,
  }) {
    return TextTheme(
          displayLarge: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: -2.2,
          ),
          displayMedium: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            height: 1.08,
            letterSpacing: -1.6,
          ),
          displaySmall: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -1.2,
          ),
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.15,
            letterSpacing: -0.8,
          ),
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.18,
            letterSpacing: -0.6,
          ),
          headlineSmall: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.22,
            letterSpacing: -0.4,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.25,
            letterSpacing: -0.3,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: -0.1,
          ),
          titleSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 0.1,
          ),
          labelMedium: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 0.2,
          ),
          labelSmall: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.2,
            letterSpacing: 0.5,
          ),
        )
        .apply(bodyColor: primaryText, displayColor: primaryText)
        .copyWith(
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: secondaryText,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.2,
            letterSpacing: 0.5,
            color: secondaryText,
          ),
        );
  }
}
