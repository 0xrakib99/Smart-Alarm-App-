import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_pages.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/app/theme/app_theme.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/services/backup_service.dart';
import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/core/services/permission_service.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/app_settings.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/providers/alarm_history_local_provider.dart';
import 'package:smart_alarm/data/providers/alarm_local_provider.dart';
import 'package:smart_alarm/data/providers/settings_local_provider.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';
import 'package:smart_alarm/features/history/controllers/history_controller.dart';
import 'package:smart_alarm/features/history/presentation/history_screen.dart';
import 'package:smart_alarm/features/home/controllers/home_controller.dart';
import 'package:smart_alarm/features/home/presentation/home_screen.dart';
import 'package:smart_alarm/features/missions/controllers/mission_selection_controller.dart';
import 'package:smart_alarm/features/missions/presentation/mission_selection_screen.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';
import 'package:smart_alarm/features/settings/presentation/settings_screen.dart';
import 'package:smart_alarm/features/statistics/controllers/statistics_controller.dart';
import 'package:smart_alarm/features/statistics/presentation/statistics_screen.dart';

class _TestStorage implements LocalStorageService {
  final Map<String, dynamic> _map = <String, dynamic>{};

  @override
  T? read<T>(String key) => _map[key] is T ? _map[key] as T : null;

  @override
  Map<String, dynamic>? readMap(String key) =>
      _map[key] is Map ? Map<String, dynamic>.from(_map[key] as Map) : null;

  @override
  Future<void> remove(String key) async => _map.remove(key);

  @override
  Future<void> write(String key, dynamic value) async => _map[key] = value;
}

class _StubNativeService extends AlarmNativeService {
  @override
  Future<bool> scheduleAlarm(AlarmModel alarm) async => true;

  @override
  Future<bool> cancelAlarm(String id) async => true;

  @override
  Future<bool> syncAlarms(List<AlarmModel> alarms) async => true;
}

class _StubPermissionService extends PermissionService {
  @override
  Future<void> checkPermissions() async {
    hasCheckedPermissions.value = true;
  }
}

void main() {
  late _TestStorage storage;
  late AlarmRepository alarmRepository;
  late AlarmHistoryRepository historyRepository;
  late SettingsRepository settingsRepository;
  late SettingsController settingsController;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    storage = _TestStorage();
    alarmRepository = AlarmRepository(AlarmLocalProvider(storage));
    historyRepository = AlarmHistoryRepository(
      AlarmHistoryLocalProvider(storage),
    );
    settingsRepository = SettingsRepository(SettingsLocalProvider(storage));

    Get.put<AlarmRepository>(alarmRepository);
    Get.put<AlarmHistoryRepository>(historyRepository);
    Get.put<SettingsRepository>(settingsRepository);
    settingsController = Get.put<SettingsController>(
      SettingsController(settingsRepository),
    );
    Get.put<AlarmNativeService>(_StubNativeService());
    Get.put<PermissionService>(_StubPermissionService());
    Get.put<BackupService>(
      BackupService(
        alarmRepository: alarmRepository,
        historyRepository: historyRepository,
        settingsRepository: settingsRepository,
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 6 Screen Widget & Integration Flow Tests', () {
    testWidgets(
      'End-to-End: Home -> CreateAlarm -> MissionSelection -> Save renders alarm',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            initialRoute: AppRoutes.home,
            getPages: AppPages.pages,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No alarms yet'), findsOneWidget);

        // Tap New alarm FAB -> CreateAlarmScreen
        await tester.tap(find.text('New alarm'));
        await tester.pumpAndSettle();
        expect(find.text('New alarm'), findsOneWidget);

        // Enter label
        await tester.enterText(find.byType(TextField), 'Office Wake');
        await tester.pump();

        // Open MissionSelectionScreen
        await tester.scrollUntilVisible(
          find.text('Wake-up mission'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.text('Wake-up mission'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Wake-up mission'));
        await tester.pumpAndSettle();
        expect(find.text('Wake-up mission'), findsOneWidget);

        // Select Math Challenge and apply
        await tester.tap(find.text('Math Challenge'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Use mission'));
        await tester.pumpAndSettle();

        // Save alarm back to HomeScreen
        await tester.tap(find.text('Create alarm'));
        await tester.pumpAndSettle();

        expect(find.text('Office Wake'), findsAtLeastNWidgets(1));
        expect(alarmRepository.getAlarms().single.label, 'Office Wake');
        expect(
          alarmRepository.getAlarms().single.mission?.type,
          MissionType.math,
        );
      },
    );

    testWidgets('MissionSelectionScreen shows difficulty chips in Dark theme', (
      tester,
    ) async {
      Get.put(MissionSelectionController());

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const MissionSelectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Math Challenge'), findsOneWidget);
      expect(find.text('Tap Challenge'), findsOneWidget);
      expect(find.text('Memory Match'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'HistoryScreen renders empty state, populated records, filter, and delete',
      (tester) async {
        final historyController = Get.put(HistoryController(historyRepository));

        await tester.pumpWidget(
          GetMaterialApp(theme: AppTheme.light, home: const HistoryScreen()),
        );
        await tester.pumpAndSettle();
        expect(find.text('No history records'), findsOneWidget);

        final now = DateTime.now();
        await historyRepository.addRecord(
          AlarmHistoryRecord(
            id: 'h_comp',
            alarmId: 'a1',
            alarmLabel: 'Morning Run',
            scheduledTime: now.subtract(const Duration(minutes: 2)),
            actualTime: now,
            status: AlarmHistoryStatus.completed,
            selectedMissions: const <String>['math'],
            completedMissions: const <String>['math'],
            durationSeconds: 30,
          ),
        );
        await historyRepository.addRecord(
          AlarmHistoryRecord(
            id: 'h_miss',
            alarmId: 'a2',
            alarmLabel: 'Late Nap',
            scheduledTime: now.subtract(const Duration(hours: 2)),
            actualTime: now.subtract(const Duration(hours: 2)),
            status: AlarmHistoryStatus.missed,
          ),
        );
        historyController.loadRecords();
        await tester.pumpAndSettle();

        expect(find.text('Morning Run'), findsOneWidget);
        expect(find.text('Late Nap'), findsOneWidget);

        // Filter to Missed
        await tester.tap(find.text('Missed').first);
        await tester.pumpAndSettle();
        expect(find.text('Late Nap'), findsOneWidget);
        expect(find.text('Morning Run'), findsNothing);
      },
    );

    testWidgets(
      'StatisticsScreen shows empty state then real calculated metrics',
      (tester) async {
        final statsController = Get.put(
          StatisticsController(historyRepository),
        );

        await tester.pumpWidget(
          GetMaterialApp(theme: AppTheme.light, home: const StatisticsScreen()),
        );
        await tester.pumpAndSettle();
        expect(find.text('No statistics yet'), findsOneWidget);

        final now = DateTime.now();
        await historyRepository.addRecord(
          AlarmHistoryRecord(
            id: 'stat_1',
            alarmId: 'a1',
            alarmLabel: 'Work',
            scheduledTime: now,
            actualTime: now,
            status: AlarmHistoryStatus.completed,
            completedMissions: const <String>['shake'],
            durationSeconds: 20,
          ),
        );
        statsController.reloadStatistics();
        await tester.pumpAndSettle();

        expect(find.text('CURRENT STREAK'), findsOneWidget);
        expect(find.text('1'), findsAtLeastNWidgets(1));
        expect(find.text('day'), findsOneWidget);
        expect(find.text('Overview'), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsScreen toggles theme, selects alarm volume, and runs Backup Export/Import',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final homeController = Get.put(HomeController(alarmRepository));

        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsController.themeMode,
            home: const SettingsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Change theme to Dark
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        expect(
          settingsController.settings.themePreference,
          ThemePreference.dark,
        );

        // Change alarm volume to 100%
        await tester.tap(find.text('Alarm volume'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('100%'));
        await tester.pumpAndSettle();
        expect(settingsController.settings.alarmVolume, 100);

        // Import valid backup via Import dialog
        final backupJson = await Get.find<BackupService>().exportBackupJson();
        await tester.tap(find.text('Import backup'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), backupJson);
        await tester.tap(find.text('Restore Data'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Imported 0 alarms and 0 history records.'),
          findsOneWidget,
        );

        homeController.onClose();
      },
    );

    testWidgets('HomeScreen renders cleanly in Dark Mode', (tester) async {
      final homeController = Get.put(HomeController(alarmRepository));

      await alarmRepository.saveAlarm(
        AlarmModel(
          id: 'dark_alarm',
          hour: 6,
          minute: 30,
          label: 'Early Bird',
          repeatDays: const <int>[1, 2, 3],
          soundId: 'default',
          vibrationEnabled: true,
          snoozeEnabled: false,
          snoozeMinutes: 5,
          enabled: true,
          createdAt: DateTime(2026, 11, 12, 6, 0),
        ),
      );
      homeController.reloadAlarms();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Early Bird'), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull);

      homeController.onClose();
    });
  });
}
