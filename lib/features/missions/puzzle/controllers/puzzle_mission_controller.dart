import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/core/services/local_storage_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/puzzle/utils/puzzle_solvability.dart';

class PuzzleMissionController extends GetxController {
  PuzzleMissionController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxList<int> tiles = <int>[].obs;
  late final int gridSize;
  late final int shuffleMoves;

  final RxInt moves = 0.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();
  late DateTime _startedAt;

  String get _storageKey => 'puzzle_state_${difficulty.name}';

  int get totalTiles => (gridSize * gridSize) - 1;

  int get tilesInPlace {
    int count = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] == i + 1) {
        count++;
      }
    }
    return count;
  }

  double get progressPercentage {
    if (totalTiles <= 0) return 0.0;
    return (tilesInPlace / totalTiles).clamp(0.0, 1.0);
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    gridSize = MissionDifficultyConfig.puzzleGridSize(resolvedDifficulty);
    shuffleMoves = MissionDifficultyConfig.puzzleShuffleMoves(
      resolvedDifficulty,
    );
    startSession();
  }

  void startSession() {
    result.value = null;
    _startedAt = DateTime.now();

    // Check for recoverable state
    if (Get.isRegistered<LocalStorageService>()) {
      final storage = Get.find<LocalStorageService>();
      final saved = storage.readMap(_storageKey);
      if (saved != null) {
        final savedTiles = (saved['tiles'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList();
        final savedMoves = (saved['moves'] as num?)?.toInt() ?? 0;
        if (savedTiles != null &&
            savedTiles.length == gridSize * gridSize &&
            !PuzzleSolvability.isSolved(savedTiles)) {
          tiles.assignAll(savedTiles);
          moves.value = savedMoves;
          status.value = MissionStatus.inProgress;
          return;
        }
      }
    }

    moves.value = 0;
    final generated = PuzzleSolvability.generateSolvablePuzzle(
      gridSize,
      shuffleMoves,
    );
    tiles.assignAll(generated);
    status.value = MissionStatus.inProgress;
    _persistState();
  }

  void restart() {
    moves.value = 0;
    result.value = null;
    _startedAt = DateTime.now();

    final generated = PuzzleSolvability.generateSolvablePuzzle(
      gridSize,
      shuffleMoves,
    );
    tiles.assignAll(generated);
    status.value = MissionStatus.inProgress;
    _persistState();
  }

  void _persistState() {
    if (Get.isRegistered<LocalStorageService>()) {
      Get.find<LocalStorageService>().write(_storageKey, <String, dynamic>{
        'tiles': tiles.toList(),
        'moves': moves.value,
      });
    }
  }

  void _clearPersistedState() {
    if (Get.isRegistered<LocalStorageService>()) {
      Get.find<LocalStorageService>().remove(_storageKey);
    }
  }

  bool canMove(int index) {
    if (index < 0 || index >= tiles.length) return false;
    final blankIndex = tiles.indexOf(0);
    if (blankIndex == -1) return false;

    final tileRow = index ~/ gridSize;
    final tileCol = index % gridSize;
    final blankRow = blankIndex ~/ gridSize;
    final blankCol = blankIndex % gridSize;

    final isSameRowAdjacent =
        tileRow == blankRow && (tileCol - blankCol).abs() == 1;
    final isSameColAdjacent =
        tileCol == blankCol && (tileRow - blankRow).abs() == 1;

    return isSameRowAdjacent || isSameColAdjacent;
  }

  void moveTile(int index) {
    if (status.value != MissionStatus.inProgress) return;
    if (!canMove(index)) return;

    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }

    final blankIndex = tiles.indexOf(0);
    final tileValue = tiles[index];

    // Swap tile with blank
    tiles[index] = 0;
    tiles[blankIndex] = tileValue;
    moves.value++;
    _persistState();

    if (moves.value > 0 && PuzzleSolvability.isSolved(tiles)) {
      _completeMission();
    }
  }

  void _completeMission() {
    if (!PuzzleSolvability.isSolved(tiles)) {
      return;
    }

    _clearPersistedState();
    status.value = MissionStatus.completed;
    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.puzzle,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: moves.value,
      attempts: moves.value,
      metrics: <String, dynamic>{
        'Grid size': '${gridSize}x$gridSize',
        'Total moves': '${moves.value}',
      },
    );
  }
}
