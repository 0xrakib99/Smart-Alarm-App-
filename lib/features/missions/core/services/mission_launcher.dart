import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';

abstract final class MissionLauncher {
  static String routeFor(MissionType type) {
    return switch (type) {
      MissionType.math => AppRoutes.mathMission,
      MissionType.tap => AppRoutes.tapMission,
      MissionType.memory => AppRoutes.memoryMission,
      MissionType.puzzle => AppRoutes.puzzleMission,
      MissionType.shake => AppRoutes.shakeMission,
      MissionType.wordScramble => AppRoutes.wordScrambleMission,
      MissionType.colorSequence => AppRoutes.colorSequenceMission,
      MissionType.typing => AppRoutes.typingMission,
    };
  }

  static Future<MissionResult?> launch(MissionConfig config) async {
    final route = routeFor(config.type);
    final result = await Get.toNamed(route, arguments: config);
    if (result is MissionResult) {
      return result;
    }
    return null;
  }
}
