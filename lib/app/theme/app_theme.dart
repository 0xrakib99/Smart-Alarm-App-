import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_alarm/app/theme/app_colors.dart';
import 'package:smart_alarm/app/theme/app_typography.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

abstract final class AppTheme {
  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        onSurfaceVariant: AppColors.lightTextMuted,
        outline: const Color(0xFF8B8196),
        outlineVariant: AppColors.lightBorder,
        surfaceContainerLowest: AppColors.lightBackground,
        surfaceContainerLow: const Color(0xFFFBF9FD),
        surfaceContainer: AppColors.lightSurfaceMuted,
        surfaceContainerHigh: const Color(0xFFF1ECF7),
        surfaceContainerHighest: const Color(0xFFEBE4F2),
        error: const Color(0xFFB3261E),
        onError: Colors.white,
      );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        onSurfaceVariant: AppColors.darkTextMuted,
        outline: const Color(0xFF8B8493),
        outlineVariant: AppColors.darkBorder,
        surfaceContainerLowest: AppColors.darkBackground,
        surfaceContainerLow: const Color(0xFF17171A),
        surfaceContainer: const Color(0xFF201F24),
        surfaceContainerHigh: AppColors.darkSurfaceMuted,
        surfaceContainerHighest: const Color(0xFF2A282F),
        error: const Color(0xFFF2B8B5),
        onError: const Color(0xFF601410),
      );

  static ThemeData get light =>
      _build(colorScheme: _lightScheme, brightness: Brightness.light);

  static ThemeData get dark =>
      _build(colorScheme: _darkScheme, brightness: Brightness.dark);

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.create(
      primaryText: colorScheme.onSurface,
      secondaryText: colorScheme.onSurfaceVariant,
    );
    final scaffoldColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final borderColor = colorScheme.outlineVariant;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: scaffoldColor,
      textTheme: textTheme,
      primaryColor: colorScheme.primary,
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: colorScheme.primary.withValues(alpha: 0.04),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleSpacing: AppConstants.horizontalPadding,
        toolbarHeight: 64,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: scaffoldColor,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: scaffoldColor,
              ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: _inputBorder(colorScheme, Colors.transparent),
        enabledBorder: _inputBorder(colorScheme, Colors.transparent),
        focusedBorder: _inputBorder(colorScheme, colorScheme.primary, 1.4),
        errorBorder: _inputBorder(colorScheme, colorScheme.error, 1.2),
        focusedErrorBorder: _inputBorder(colorScheme, colorScheme.error, 1.4),
        disabledBorder: _inputBorder(colorScheme, Colors.transparent),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.primary.withValues(alpha: 0.38);
            }
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onPrimary.withValues(alpha: 0.9);
            }
            return colorScheme.onPrimary;
          }),
          overlayColor: WidgetStatePropertyAll<Color>(
            colorScheme.onPrimary.withValues(alpha: 0.08),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.labelLarge?.copyWith(fontSize: 15),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 50)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.primary),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: borderColor),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.primary),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color>(
            colorScheme.onSurfaceVariant,
          ),
          overlayColor: WidgetStatePropertyAll<Color>(
            colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.sheetRadius),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.2),
        selectionHandleColor: colorScheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    ColorScheme colorScheme,
    Color color, [
    double width = 0,
  ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
