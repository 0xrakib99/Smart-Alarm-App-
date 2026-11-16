import 'package:get/get.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';
import 'package:smart_alarm/features/statistics/domain/statistics_calculator.dart';
import 'package:smart_alarm/features/statistics/domain/statistics_summary.dart';

class StatisticsController extends GetxController {
  StatisticsController(this._historyRepository);

  final AlarmHistoryRepository _historyRepository;

  final Rx<StatisticsSummary> summary = StatisticsSummary.empty.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    reloadStatistics();
  }

  void reloadStatistics() {
    isLoading.value = true;
    final records = _historyRepository.getAll();
    summary.value = StatisticsCalculator.calculate(records);
    isLoading.value = false;
  }
}
