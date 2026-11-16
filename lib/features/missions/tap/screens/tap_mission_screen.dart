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
import 'package:smart_alarm/features/missions/tap/controllers/tap_mission_controller.dart';
import 'package:smart_alarm/features/missions/tap/widgets/tap_target_widget.dart';

class TapMissionScreen extends GetView<TapMissionController> {
  const TapMissionScreen({super.key});

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
            title: 'Tap Challenge',
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
                        current: controller.successfulTaps.value,
                        total: controller.targetCount,
                        label:
                            'Targets: ${controller.successfulTaps.value} of ${controller.targetCount}',
                      ),
                      const SizedBox(height: 20),
                      const MissionInstruction(
                        icon: Icons.touch_app_outlined,
                        instruction: 'Tap the moving target',
                        subInstruction:
                            'React quickly and hit each target before it repositions.',
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final targetSize = controller.targetSize;
                            final usableWidth =
                                (constraints.maxWidth - targetSize).clamp(
                                  0.0,
                                  double.infinity,
                                );
                            final usableHeight =
                                (constraints.maxHeight - targetSize).clamp(
                                  0.0,
                                  double.infinity,
                                );

                            return AppCard(
                              padding: EdgeInsets.zero,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: controller.onMissedPlayAreaTap,
                                child: Stack(
                                  children: <Widget>[
                                    Obx(() {
                                      final posX =
                                          controller.targetNormX.value *
                                          usableWidth;
                                      final posY =
                                          controller.targetNormY.value *
                                          usableHeight;

                                      return Positioned(
                                        left: posX,
                                        top: posY,
                                        child: TapTargetWidget(
                                          size: targetSize,
                                          onTap: controller.onTapTarget,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
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
