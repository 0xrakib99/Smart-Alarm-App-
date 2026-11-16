import 'dart:math';

abstract final class PuzzleSolvability {
  /// Counts inversions ignoring the empty tile (0).
  static int countInversions(List<int> tiles) {
    int inversions = 0;
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] == 0) continue;
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[j] == 0) continue;
        if (tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }
    return inversions;
  }

  /// Checks if a tile configuration is mathematically solvable.
  /// Standard N-puzzle solvability theorem:
  /// - If N is odd, solvable <=> inversions is even.
  /// - If N is even, solvable <=> (inversions is even and blank on odd row from bottom)
  ///                         or (inversions is odd and blank on even row from bottom).
  static bool isSolvable(List<int> tiles, int gridSize) {
    final inversions = countInversions(tiles);
    if (gridSize % 2 != 0) {
      // Grid width is odd (3x3, 5x5)
      return inversions % 2 == 0;
    } else {
      // Grid width is even (4x4)
      final blankIndex = tiles.indexOf(0);
      final blankRowFromTop = blankIndex ~/ gridSize;
      final blankRowFromBottom = gridSize - blankRowFromTop;
      if (blankRowFromBottom % 2 == 1) {
        // Odd row from bottom
        return inversions % 2 == 0;
      } else {
        // Even row from bottom
        return inversions % 2 == 1;
      }
    }
  }

  /// Checks if the puzzle is in its goal solved state: 1, 2, ..., N^2-1, 0.
  static bool isSolved(List<int> tiles) {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) {
        return false;
      }
    }
    return tiles.last == 0;
  }

  /// Generates a solvable, scrambled puzzle guaranteed not to be already solved.
  static List<int> generateSolvablePuzzle(int gridSize, int shuffleMoves) {
    final random = Random();
    final total = gridSize * gridSize;

    // Start with solved state
    final tiles = List<int>.generate(total - 1, (i) => i + 1)..add(0);

    // Perform random legal walk moves from solved state to guarantee physical solvability
    int blankIndex = total - 1;
    int lastMovedTile = -1;

    for (int step = 0; step < shuffleMoves; step++) {
      final validNeighbors = _getValidNeighbors(blankIndex, gridSize);
      // Try to avoid immediately reverting the last move
      final candidates = validNeighbors.length > 1
          ? validNeighbors.where((idx) => tiles[idx] != lastMovedTile).toList()
          : validNeighbors;

      final chosenIndex = candidates.isEmpty
          ? validNeighbors[random.nextInt(validNeighbors.length)]
          : candidates[random.nextInt(candidates.length)];

      lastMovedTile = tiles[chosenIndex];
      // Swap blank with chosen tile
      tiles[blankIndex] = tiles[chosenIndex];
      tiles[chosenIndex] = 0;
      blankIndex = chosenIndex;
    }

    // Mathematical verification
    assert(
      isSolvable(tiles, gridSize),
      'Puzzle must be mathematically solvable',
    );

    // If somehow ended up solved, perform two more random moves
    if (isSolved(tiles)) {
      final validNeighbors = _getValidNeighbors(blankIndex, gridSize);
      final moveIdx = validNeighbors[random.nextInt(validNeighbors.length)];
      tiles[blankIndex] = tiles[moveIdx];
      tiles[moveIdx] = 0;
    }

    return tiles;
  }

  static List<int> _getValidNeighbors(int blankIndex, int gridSize) {
    final neighbors = <int>[];
    final row = blankIndex ~/ gridSize;
    final col = blankIndex % gridSize;

    // Up
    if (row > 0) neighbors.add(blankIndex - gridSize);
    // Down
    if (row < gridSize - 1) neighbors.add(blankIndex + gridSize);
    // Left
    if (col > 0) neighbors.add(blankIndex - 1);
    // Right
    if (col < gridSize - 1) neighbors.add(blankIndex + 1);

    return neighbors;
  }
}
