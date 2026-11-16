import 'package:get/get.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/features/alarm/controllers/create_alarm_controller.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';

class CreateAlarmBinding extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments;
    final alarm = arguments is AlarmModel ? arguments : null;

    Get.lazyPut<CreateAlarmController>(
      () => CreateAlarmController(
        Get.find<AlarmRepository>(),
        settingsController: Get.find<SettingsController>(),
        alarm: alarm,
      ),
    );
  }
}
