import 'package:get/get.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/features/statistics/controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsController>(
      () => StatisticsController(Get.find<AlarmHistoryRepository>()),
    );
  }
}
