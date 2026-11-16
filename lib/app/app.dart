import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_pages.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';

class SmartAlarmApp extends StatelessWidget {
  const SmartAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return GetBuilder<SettingsController>(
      init: settingsController,
      builder: (controller) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.themeMode,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 240),
        );
      },
    );
  }
}
