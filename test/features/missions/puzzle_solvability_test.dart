import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/features/missions/puzzle/utils/puzzle_solvability.dart';

void main() {
  group('PuzzleSolvability', () {
    test('detects solved state correctly', () {
      expect(
        PuzzleSolvability.isSolved(<int>[1, 2, 3, 4, 5, 6, 7, 8, 0]),
        isTrue,
      );
      expect(
        PuzzleSolvability.isSolved(<int>[1, 2, 3, 4, 5, 6, 7, 0, 8]),
        isFalse,
      );
    });

    test('correctly calculates inversions', () {
      // Inversions in [1, 2, 3, 4, 5, 6, 7, 8, 0] = 0
      expect(
        PuzzleSolvability.countInversions(<int>[1, 2, 3, 4, 5, 6, 7, 8, 0]),
        0,
      );
      // Inversions in [2, 1, 3, 4, 5, 6, 7, 8, 0] = 1 (2 > 1)
      expect(
        PuzzleSolvability.countInversions(<int>[2, 1, 3, 4, 5, 6, 7, 8, 0]),
        1,
      );
    });

    test('validates 3x3 odd grid solvability', () {
      // Solved is solvable (0 inversions -> even)
      expect(
        PuzzleSolvability.isSolvable(<int>[1, 2, 3, 4, 5, 6, 7, 8, 0], 3),
        isTrue,
      );
      // Single swap of two tiles has 1 inversion -> odd -> unsolvable
      expect(
        PuzzleSolvability.isSolvable(<int>[2, 1, 3, 4, 5, 6, 7, 8, 0], 3),
        isFalse,
      );
    });

    test('validates 4x4 even grid solvability (Loyd 15-puzzle impossibility)', () {
      // The classic impossible 15-puzzle has tiles 14 and 15 swapped, blank at bottom (row 1 from bottom).
      // Blank is on odd row from bottom (1), inversions = 1 (odd) -> unsolvable!
      final impossible15 = <int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        15,
        14,
        0,
      ];
      expect(PuzzleSolvability.isSolvable(impossible15, 4), isFalse);

      // Normal solved 15-puzzle: blank row = 1 (odd), inversions = 0 (even) -> solvable!
      final solved15 = <int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        0,
      ];
      expect(PuzzleSolvability.isSolvable(solved15, 4), isTrue);
    });

    test(
      'generateSolvablePuzzle always produces mathematically solvable scrambled puzzles',
      () {
        for (final size in <int>[3, 4, 5]) {
          for (int i = 0; i < 5; i++) {
            final puzzle = PuzzleSolvability.generateSolvablePuzzle(size, 30);
            expect(puzzle.length, size * size);
            expect(puzzle.contains(0), isTrue);
            expect(PuzzleSolvability.isSolvable(puzzle, size), isTrue);
            expect(PuzzleSolvability.isSolved(puzzle), isFalse);
          }
        }
      },
    );
  });
}
