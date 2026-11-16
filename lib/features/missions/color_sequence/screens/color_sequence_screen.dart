import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/features/missions/color_sequence/controllers/color_sequence_controller.dart';
import 'package:smart_alarm/features/missions/color_sequence/models/sequence_color.dart';
import 'package:smart_alarm/features/missions/color_sequence/widgets/color_sequence_pad.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';

class ColorSequenceScreen extends GetView<ColorSequenceController> {
  const ColorSequenceScreen({super.key});

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

      final isLocked = controller.isDemonstrating.value;
      final flashColor = controller.activeFlashColor.value;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            await MissionAlarmBanner.handleExit(context);
          }
        },
        child: Scaffold(
          appBar: MissionHeader(
            title: 'Color Sequence',
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
                        current: controller.currentRound.value,
                        total: controller.targetLength,
                        label:
                            'Round ${controller.currentRound.value} of ${controller.targetLength}',
                        secondaryText:
                            'Input: ${controller.userInputs.length}/${controller.currentRound.value}',
                      ),
                      const SizedBox(height: 16),
                      const MissionInstruction(
                        icon: Icons.palette_rounded,
                        instruction: 'Memorize the color sequence',
                        subInstruction:
                            'Watch the glowing pattern, then tap the colored pads in the exact same sequence.',
                      ),
                      const SizedBox(height: 14),

                      // Status & Sequence indicators
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  isLocked
                                      ? Icons.visibility_rounded
                                      : Icons.touch_app_rounded,
                                  size: 18,
                                  color: isLocked
                                      ? colorScheme.primary
                                      : colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  controller.feedbackMessage.value ??
                                      (isLocked
                                          ? 'Watch sequence...'
                                          : 'Your turn!'),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: controller.hasError.value
                                        ? colorScheme.error
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Dots representing user input progress in current round
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.currentRound.value,
                                (index) {
                                  final hasInput =
                                      index < controller.userInputs.length;
                                  final color = hasInput
                                      ? controller.userInputs[index].baseColor
                                      : colorScheme.outlineVariant;

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2x2 Color Pads
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              physics: const NeverScrollableScrollPhysics(),
                              children: SequenceColor.values
                                  .map((col) {
                                    return ColorSequencePad(
                                      color: col,
                                      isFlashing: flashColor == col,
                                      isLocked: isLocked,
                                      onTap: () => controller.tapColor(col),
                                    );
                                  })
                                  .toList(growable: false),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
