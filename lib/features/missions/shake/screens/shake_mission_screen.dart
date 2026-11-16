import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/shake/controllers/shake_mission_controller.dart';
import 'package:smart_alarm/features/missions/shake/widgets/shake_progress_gauge.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_action_button.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_alarm_banner.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_header.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_instruction.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_progress.dart';

class ShakeMissionScreen extends GetView<ShakeMissionController> {
  const ShakeMissionScreen({super.key});

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
            title: 'Shake Challenge',
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
                        current: controller.currentShakes.value,
                        total: controller.requiredShakes,
                        label:
                            'Progress: ${controller.currentShakes.value} of ${controller.requiredShakes}',
                      ),
                      const SizedBox(height: 20),
                      const MissionInstruction(
                        icon: Icons.vibration_rounded,
                        instruction: 'Shake your phone',
                        subInstruction:
                            'Vigorously shake the phone to build up and complete the progress.',
                      ),
                      const Spacer(),
                      ShakeProgressGauge(
                        current: controller.currentShakes.value,
                        total: controller.requiredShakes,
                        intensity: controller.currentMagnitude.value,
                      ),
                      const Spacer(),
                      if (!controller.isSensorAvailable.value) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Accelerometer sensor unavailable on this device. You can tap below to simulate shakes.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        MissionActionButton(
                          label: 'Simulate Shake',
                          icon: Icons.touch_app_rounded,
                          isSecondary: true,
                          onPressed: controller.manualShake,
                        ),
                      ],
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
