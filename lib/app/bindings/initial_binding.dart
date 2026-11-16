import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/core/services/backup_service.dart';
import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/core/services/permission_service.dart';
import 'package:smart_alarm/data/providers/alarm_history_local_provider.dart';
import 'package:smart_alarm/data/providers/alarm_local_provider.dart';
import 'package:smart_alarm/data/providers/settings_local_provider.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/data/repositories/settings_repository.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = Get.find<LocalStorageService>();

    final settingsProvider = SettingsLocalProvider(storage);
    final settingsRepository = SettingsRepository(settingsProvider);
    final alarmProvider = AlarmLocalProvider(storage);
    final alarmRepository = AlarmRepository(alarmProvider);
    final historyProvider = AlarmHistoryLocalProvider(storage);
    final historyRepository = AlarmHistoryRepository(historyProvider);

    Get.put<SettingsLocalProvider>(settingsProvider, permanent: true);
    Get.put<SettingsRepository>(settingsRepository, permanent: true);
    Get.put<AlarmLocalProvider>(alarmProvider, permanent: true);
    Get.put<AlarmRepository>(alarmRepository, permanent: true);
    Get.put<AlarmHistoryLocalProvider>(historyProvider, permanent: true);
    Get.put<AlarmHistoryRepository>(historyRepository, permanent: true);

    Get.put<SettingsController>(
      SettingsController(settingsRepository),
      permanent: true,
    );

    Get.put<BackupService>(
      BackupService(
        alarmRepository: alarmRepository,
        historyRepository: historyRepository,
        settingsRepository: settingsRepository,
      ),
      permanent: true,
    );

    Get.put<PermissionService>(PermissionService(), permanent: true);
    final alarmNativeService = Get.put<AlarmNativeService>(
      AlarmNativeService(),
      permanent: true,
    );
    Get.put<AlarmStateService>(
      AlarmStateService(
        nativeService: alarmNativeService,
        alarmRepository: alarmRepository,
        historyRepository: historyRepository,
      ),
      permanent: true,
    );

    // Initial sync of all alarms with native AlarmManager
    final alarms = alarmRepository.getAlarms();
    if (alarms.isNotEmpty) {
      alarmNativeService.syncAlarms(alarms);
    }
  }
}
