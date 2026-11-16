import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/puzzle/controllers/puzzle_mission_controller.dart';
import 'package:smart_alarm/features/missions/puzzle/widgets/puzzle_board.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';

class PuzzleMissionScreen extends GetView<PuzzleMissionController> {
  const PuzzleMissionScreen({super.key});

  Future<void> _showRestartConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Restart Puzzle?'),
          content: const Text(
            'Are you sure you want to reshuffle the board? Your current move count will reset.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      controller.restart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final status = controller.status.value;
      if (status == MissionStatus.completed) {
        final result = controller.result.value;
        if (result != null) {
          return MissionCompletionScreen(result: result);
        }
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            await MissionAlarmBanner.handleExit(context);
          }
        },
        child: Scaffold(
          appBar: MissionHeader(
            title: 'Number Puzzle',
            difficulty: controller.difficulty,
            onExitPressed: () => MissionAlarmBanner.handleExit(context),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Restart Puzzle',
                onPressed: () => _showRestartConfirmation(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.pageMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const MissionAlarmBanner(),
                      MissionProgress(
                        current: controller.tilesInPlace,
                        total: controller.totalTiles,
                        label: 'Moves: ${controller.moves.value}',
                        secondaryText:
                            'Placed: ${controller.tilesInPlace}/${controller.totalTiles}',
                      ),
                      const SizedBox(height: 16),
                      const MissionInstruction(
                        icon: Icons.format_list_numbered_rounded,
                        instruction: 'Order the numbers',
                        subInstruction:
                            'Slide adjacent tiles into the empty space to arrange 1 to N in ascending order.',
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: PuzzleBoard(
                              gridSize: controller.gridSize,
                              tiles: controller.tiles,
                              canMove: controller.canMove,
                              onTileTapped: controller.moveTile,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRestartConfirmation(context),
                          icon: const Icon(Icons.restart_alt_rounded, size: 18),
                          label: const Text('Restart Board'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
