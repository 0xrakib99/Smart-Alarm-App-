import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';
import 'package:smart_alarm/features/missions/word_scramble/controllers/word_scramble_controller.dart';
import 'package:smart_alarm/features/missions/word_scramble/widgets/word_scramble_letter_tile.dart';

class WordScrambleScreen extends GetView<WordScrambleController> {
  const WordScrambleScreen({super.key});

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

      final word = controller.currentWord.value;
      final targetLength = word?.originalWord.length ?? 0;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            await MissionAlarmBanner.handleExit(context);
          }
        },
        child: Scaffold(
          appBar: MissionHeader(
            title: 'Word Scramble',
            difficulty: controller.difficulty,
            onExitPressed: () => MissionAlarmBanner.handleExit(context),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.lightbulb_outline_rounded),
                tooltip: 'Use Hint (1 available)',
                onPressed: controller.hintsUsed.value < 1
                    ? () => controller.useHint()
                    : null,
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
                        current: controller.currentIndex.value + 1,
                        total: controller.totalWords,
                        label:
                            'Word ${controller.currentIndex.value + 1} of ${controller.totalWords}',
                        secondaryText: '${controller.difficulty.label} mode',
                      ),
                      const SizedBox(height: 16),
                      const MissionInstruction(
                        icon: Icons.spellcheck_rounded,
                        instruction: 'Unscramble the word',
                        subInstruction:
                            'Tap letters from the pool below to spell the correct English word.',
                      ),
                      const SizedBox(height: 18),

                      // Scrambled hint display
                      if (word != null)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallRadius,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.shuffle_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Scrambled: ${word.scrambledWord}',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    letterSpacing: 2.0,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),

                      // Answer slots
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 12,
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'YOUR ANSWER',
                              style: theme.textTheme.labelSmall?.copyWith(
                                letterSpacing: 1.2,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: List.generate(targetLength, (index) {
                                final hasLetter =
                                    index < controller.selectedLetters.length;
                                final letter = hasLetter
                                    ? controller.selectedLetters[index]
                                    : '';

                                return WordScrambleLetterTile(
                                  letter: letter,
                                  isSelected: hasLetter,
                                  size: targetLength > 6 ? 44.0 : 50.0,
                                  onTap: hasLetter
                                      ? () => controller.unselectLetter(index)
                                      : null,
                                );
                              }),
                            ),
                            if (controller.feedbackMessage.value !=
                                null) ...<Widget>[
                              const SizedBox(height: 12),
                              Text(
                                controller.feedbackMessage.value!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: controller.isCorrect.value
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Letter bank
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'AVAILABLE LETTERS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.2,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: List.generate(
                                  controller.availableLetters.length,
                                  (index) {
                                    final letter =
                                        controller.availableLetters[index];
                                    return WordScrambleLetterTile(
                                      letter: letter,
                                      isSelected: false,
                                      size: targetLength > 6 ? 44.0 : 50.0,
                                      onTap: () =>
                                          controller.selectBankLetter(index),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Controls: Backspace, Clear, Submit
                      Row(
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: controller.selectedLetters.isNotEmpty
                                ? controller.clearAnswer
                                : null,
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            label: const Text('Clear'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: controller.selectedLetters.isNotEmpty
                                ? controller.backspace
                                : null,
                            icon: const Icon(
                              Icons.backspace_outlined,
                              size: 18,
                            ),
                            label: const Text('Undo'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  controller.selectedLetters.length ==
                                      targetLength
                                  ? controller.submitAnswer
                                  : null,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 48),
                              ),
                              child: const Text('Submit'),
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
