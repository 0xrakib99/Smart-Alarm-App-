import 'package:get/get.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/data/repositories/alarm_history_repository.dart';

enum HistoryDateFilter {
  all,
  today,
  past7Days,
  past30Days;

  String get label => switch (this) {
    HistoryDateFilter.all => 'All time',
    HistoryDateFilter.today => 'Today',
    HistoryDateFilter.past7Days => '7 Days',
    HistoryDateFilter.past30Days => '30 Days',
  };
}

class HistoryController extends GetxController {
  HistoryController(this._repository);

  final AlarmHistoryRepository _repository;

  final RxList<AlarmHistoryRecord> _records = <AlarmHistoryRecord>[].obs;
  final Rxn<AlarmHistoryStatus> selectedStatus = Rxn<AlarmHistoryStatus>();
  final Rx<HistoryDateFilter> dateFilter = HistoryDateFilter.all.obs;
  final RxBool newestFirst = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  void loadRecords() {
    _records.assignAll(_repository.getAll(newestFirst: newestFirst.value));
  }

  List<AlarmHistoryRecord> get filteredRecords {
    final status = selectedStatus.value;
    final filter = dateFilter.value;
    final now = DateTime.now();

    DateTime? from;
    if (filter == HistoryDateFilter.today) {
      from = DateTime(now.year, now.month, now.day);
    } else if (filter == HistoryDateFilter.past7Days) {
      from = now.subtract(const Duration(days: 7));
    } else if (filter == HistoryDateFilter.past30Days) {
      from = now.subtract(const Duration(days: 30));
    }

    final result = _records.where((record) {
      if (status != null && record.status != status) {
        return false;
      }
      if (from != null && record.actualTime.isBefore(from)) {
        return false;
      }
      return true;
    }).toList();

    result.sort((a, b) {
      final comp = a.actualTime.compareTo(b.actualTime);
      return newestFirst.value ? -comp : comp;
    });

    return result;
  }

  void setStatusFilter(AlarmHistoryStatus? status) {
    selectedStatus.value = status;
  }

  void setDateFilter(HistoryDateFilter filter) {
    dateFilter.value = filter;
  }

  void toggleSortOrder() {
    newestFirst.value = !newestFirst.value;
  }

  Future<bool> deleteRecord(String id) async {
    final deleted = await _repository.deleteRecord(id);
    if (deleted) {
      _records.removeWhere((r) => r.id == id);
    }
    return deleted;
  }

  Future<bool> clearAllHistory() async {
    final cleared = await _repository.clearHistory();
    if (cleared) {
      _records.clear();
    }
    return cleared;
  }
}
