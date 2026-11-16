import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/features/alarm/controllers/alarm_ringing_controller.dart';

class AlarmRingingBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final alarm = args is AlarmModel ? args : null;

    Get.lazyPut<AlarmRingingController>(
      () => AlarmRingingController(
        alarmStateService: Get.find<AlarmStateService>(),
        alarm: alarm,
      ),
    );
  }
}
