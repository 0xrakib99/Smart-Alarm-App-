import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/core/services/permission_service.dart';
import 'package:smart_alarm/features/permissions/presentation/permissions_screen.dart';

class _TestPermissionService extends PermissionService {
  bool exactRequested = false;
  bool notificationRequested = false;
  bool fullScreenRequested = false;

  @override
  Future<void> checkPermissions() async {
    hasCheckedPermissions.value = true;
  }

  @override
  Future<void> requestExactAlarmPermission() async {
    exactRequested = true;
  }

  @override
  Future<void> requestNotificationPermission() async {
    notificationRequested = true;
  }

  @override
  Future<void> requestFullScreenIntentPermission() async {
    fullScreenRequested = true;
  }
}

void main() {
  late _TestPermissionService permService;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    permService = Get.put<_TestPermissionService>(_TestPermissionService());
    Get.put<PermissionService>(permService);
  });

  tearDown(() {
    Get.reset();
  });

  group('PermissionsScreen & PermissionService', () {
    testWidgets('shows Action Required buttons when permissions are missing', (
      tester,
    ) async {
      permService.exactAlarmGranted.value = false;
      permService.notificationGranted.value = false;
      permService.fullScreenIntentGranted.value = false;

      expect(permService.hasAllRequiredPermissions, isFalse);

      await tester.pumpWidget(
        GetMaterialApp(theme: AppTheme.light, home: const PermissionsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Exact Alarm Scheduling'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Full-Screen Intent'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Full-Screen Intent'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Exact Alarm Scheduling'),
        -200,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enable in Settings').first);
      await tester.pump();
      expect(permService.exactRequested, isTrue);

      await tester.tap(find.text('Allow Notifications'));
      await tester.pump();
      expect(permService.notificationRequested, isTrue);

      await tester.scrollUntilVisible(find.text('Full-Screen Intent'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enable in Settings').last);
      await tester.pump();
      expect(permService.fullScreenRequested, isTrue);
    });

    testWidgets('shows Granted statuses cleanly in Dark theme', (tester) async {
      permService.exactAlarmGranted.value = true;
      permService.notificationGranted.value = true;
      permService.fullScreenIntentGranted.value = true;

      expect(permService.hasAllRequiredPermissions, isTrue);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const PermissionsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Granted'), findsNWidgets(2));
      expect(find.text('Active'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
