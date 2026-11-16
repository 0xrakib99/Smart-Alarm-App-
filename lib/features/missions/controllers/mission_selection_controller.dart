import 'package:get/get.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/core/services/mission_launcher.dart';

class MissionSelectionController extends GetxController {
  MissionSelectionController({dynamic initialSelection}) {
    if (initialSelection is List<MissionConfig>) {
      for (final config in initialSelection) {
        _selectedMissions[config.type] = config.difficulty;
      }
    } else if (initialSelection is MissionConfig) {
      _selectedMissions[initialSelection.type] = initialSelection.difficulty;
    }
  }

  final RxMap<MissionType, MissionDifficulty> _selectedMissions =
      <MissionType, MissionDifficulty>{}.obs;
  final Rxn<MissionResult> lastResult = Rxn<MissionResult>();

  bool isSelected(MissionType type) => _selectedMissions.containsKey(type);

  MissionDifficulty getDifficulty(MissionType type) =>
      _selectedMissions[type] ?? MissionDifficulty.easy;

  int get selectedCount => _selectedMissions.length;

  bool get hasSelection => _selectedMissions.isNotEmpty;

  List<MissionConfig> get selections {
    return _selectedMissions.entries
        .map((e) => MissionConfig(type: e.key, difficulty: e.value))
        .toList(growable: false);
  }

  // Backwards-compatible accessors
  MissionConfig? get selection =>
      selections.isNotEmpty ? selections.first : null;

  MissionType? get selectedType => selection?.type;

  MissionDifficulty get difficulty =>
      selection?.difficulty ?? MissionDifficulty.easy;

  void toggleMission(MissionType type) {
    if (_selectedMissions.containsKey(type)) {
      _selectedMissions.remove(type);
    } else {
      _selectedMissions[type] = MissionDifficulty.easy;
    }
  }

  void selectMission(MissionType type) => toggleMission(type);

  void setMissionDifficulty(MissionType type, MissionDifficulty difficulty) {
    _selectedMissions[type] = difficulty;
  }

  void setDifficulty(MissionDifficulty difficulty) {
    final firstType = selectedType;
    if (firstType != null) {
      _selectedMissions[firstType] = difficulty;
    }
  }

  Future<MissionResult?> testMission([
    MissionType? type,
    MissionDifficulty? diff,
  ]) async {
    final targetType = type ?? selectedType;
    if (targetType == null) {
      return null;
    }
    final targetDiff = diff ?? getDifficulty(targetType);

    final config = MissionConfig(type: targetType, difficulty: targetDiff);
    final res = await MissionLauncher.launch(config);
    if (res != null) {
      lastResult.value = res;
    }
    return res;
  }
}
