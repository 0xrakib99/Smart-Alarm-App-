import 'package:flutter/material.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/features/missions/puzzle/widgets/puzzle_tile.dart';

class PuzzleBoard extends StatelessWidget {
  const PuzzleBoard({
    super.key,
    required this.gridSize,
    required this.tiles,
    required this.canMove,
    required this.onTileTapped,
  });

  final int gridSize;
  final List<int> tiles;
  final bool Function(int index) canMove;
  final ValueChanged<int> onTileTapped;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final value = tiles[index];
            final movable = canMove(index);
            return PuzzleTile(
              value: value,
              isMovable: movable,
              onTap: () => onTileTapped(index),
            );
          },
        ),
      ),
    );
  }
}
