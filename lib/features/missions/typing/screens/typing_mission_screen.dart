import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';
import 'package:smart_alarm/features/missions/typing/controllers/typing_mission_controller.dart';
import 'package:smart_alarm/features/missions/typing/widgets/typing_sentence_viewer.dart';

class TypingMissionScreen extends GetView<TypingMissionController> {
  const TypingMissionScreen({super.key});

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
            title: 'Typing Challenge',
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
                        current: controller.currentIndex.value + 1,
                        total: controller.totalSentences,
                        label:
                            'Sentence ${controller.currentIndex.value + 1} of ${controller.totalSentences}',
                        secondaryText:
                            'Accuracy: ${controller.accuracy.value}%',
                      ),
                      const SizedBox(height: 14),
                      const MissionInstruction(
                        icon: Icons.keyboard_rounded,
                        instruction: 'Type the sentence accurately',
                        subInstruction:
                            'Enter the exact morning sentence including punctuation and capitalization.',
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TypingSentenceViewer(
                                targetSentence: controller.targetSentence.value,
                                typedText: controller.typedText.value,
                              ),
                              const SizedBox(height: 16),

                              // Text field input
                              AppCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'TYPE HERE',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                letterSpacing: 1.2,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          '${controller.accuracy.value}% accuracy',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color:
                                                    controller.accuracy.value >
                                                        90
                                                    ? const Color(0xFF2E7D32)
                                                    : colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: controller.textController,
                                      focusNode: controller.focusNode,
                                      autofocus: true,
                                      maxLines: 3,
                                      onChanged: controller.onTextChanged,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: const InputDecoration(
                                        hintText: 'Start typing here...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.feedbackMessage.value !=
                                  null) ...<Widget>[
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    controller.feedbackMessage.value!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: controller.isCorrect.value
                                          ? const Color(0xFF2E7D32)
                                          : colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bottom actions: Clear and Submit
                      Row(
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: controller.typedText.value.isNotEmpty
                                ? controller.clearText
                                : null,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  controller.typedText.value.trim().isNotEmpty
                                  ? controller.submitSentence
                                  : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 48),
                              ),
                              child: const Text('Submit Sentence'),
                            ),
                          ),
                        ],
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
