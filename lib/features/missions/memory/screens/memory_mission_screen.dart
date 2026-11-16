import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/memory/controllers/memory_mission_controller.dart';
import 'package:smart_alarm/features/missions/memory/widgets/memory_card_tile.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';

class MemoryMissionScreen extends GetView<MemoryMissionController> {
  const MemoryMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Memory Match',
            difficulty: controller.difficulty,
            onExitPressed: () => MissionAlarmBanner.handleExit(context),
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
                        current: controller.matchedPairs.value,
                        total: controller.totalPairs,
                        label:
                            'Pairs: ${controller.matchedPairs.value} of ${controller.totalPairs}',
                        secondaryText: 'Moves: ${controller.moves.value}',
                      ),
                      const SizedBox(height: 20),
                      const MissionInstruction(
                        icon: Icons.grid_view_rounded,
                        instruction: 'Match all pairs',
                        subInstruction:
                            'Turn over two cards at a time to find matching icons.',
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: controller.gridColumns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.0,
                                  ),
                              itemCount: controller.cards.length,
                              itemBuilder: (context, index) {
                                return MemoryCardTile(
                                  card: controller.cards[index],
                                  onTap: () => controller.onCardTapped(index),
                                );
                              },
                            );
                          },
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
