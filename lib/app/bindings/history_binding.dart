import 'package:get/get.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/features/history/controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<AlarmHistoryRepository>()),
    );
  }
}
