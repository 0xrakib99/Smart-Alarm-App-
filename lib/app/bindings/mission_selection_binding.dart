import 'package:get/get.dart';
import 'package:smart_alarm/features/missions/controllers/mission_selection_controller.dart';

class MissionSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissionSelectionController>(
      () => MissionSelectionController(initialSelection: Get.arguments),
    );
  }
}
