import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

void main() {
  group('AppTheme', () {
    test('uses the light brand palette by default', () {
      final theme = AppTheme.light;

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF582493));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
    });

    test('provides a complete dark theme', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, const Color(0xFF582493));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(theme.colorScheme.surface, const Color(0xFF1B1B1E));
    });

    test('defines the shared typography and component styles', () {
      final theme = AppTheme.light;

      expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w600);
      expect(theme.textTheme.displayLarge?.fontSize, 60);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.filledButtonTheme.style, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.cardTheme.color, isNull);
      expect(AppConstants.appVersion, isNotEmpty);
    });
  });
}
