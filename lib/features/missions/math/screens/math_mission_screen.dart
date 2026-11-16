import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/math/controllers/math_mission_controller.dart';
import 'package:smart_alarm/features/missions/math/widgets/math_option_button.dart';
import 'package:smart_alarm/features/missions/math/widgets/math_question_card.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';

class MathMissionScreen extends GetView<MathMissionController> {
  const MathMissionScreen({super.key});

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
            title: 'Math Challenge',
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
                        total: controller.totalQuestions,
                        label:
                            'Question ${controller.currentIndex.value + 1} of ${controller.totalQuestions}',
                      ),
                      const SizedBox(height: 24),
                      const MissionInstruction(
                        icon: Icons.calculate_outlined,
                        instruction: 'Select the correct answer',
                        subInstruction:
                            'Solve each arithmetic problem to complete the mission.',
                      ),
                      const SizedBox(height: 24),
                      if (controller.currentProblem.value != null) ...<Widget>[
                        MathQuestionCard(
                          expression:
                              controller.currentProblem.value!.expression,
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.5,
                            physics: const NeverScrollableScrollPhysics(),
                            children: controller.currentProblem.value!.options
                                .map((option) {
                                  final isSelected =
                                      controller.selectedOption.value == option;
                                  return MathOptionButton(
                                    value: option,
                                    isSelected: isSelected,
                                    isCorrect: isSelected
                                        ? controller.lastAnswerCorrect.value
                                        : null,
                                    disabled: controller.isEvaluating.value,
                                    onTap: () =>
                                        controller.selectAnswer(option),
                                  );
                                })
                                .toList(growable: false),
                          ),
                        ),
                      ],
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
