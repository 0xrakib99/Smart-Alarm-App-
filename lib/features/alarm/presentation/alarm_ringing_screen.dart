import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/alarm/controllers/alarm_ringing_controller.dart';
import 'package:smart_alarm/features/missions/shared/screens/mission_completion_screen.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_action_button.dart';

class AlarmRingingScreen extends GetView<AlarmRingingController> {
  const AlarmRingingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final alarmStateService = Get.find<AlarmStateService>();

    return Obx(() {
      final state = alarmStateService.currentState.value;

      if (state == AlarmState.completed) {
        final lastResult = alarmStateService.lastMissionResult.value;
        if (lastResult != null) {
          return MissionCompletionScreen(
            result: lastResult,
            onDismiss: controller.onDismiss,
          );
        }
      }

      final isSoundPaused = controller.isSoundPaused;
      final wasResumedInactivity = controller.wasSoundResumedDueToInactivity;
      final wasResumedMaxDuration = controller.wasSoundResumedDueToMaxDuration;
      final areMissionsDone = controller.areMissionsCompleted;
      final alarmError = controller.alarmError;

      return PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.pageMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.horizontalPadding,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Spacer(),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSoundPaused
                                ? Icons.volume_off_rounded
                                : Icons.alarm_on_rounded,
                            size: 42,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.timeFormatted,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        controller.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      if (alarmError != null) ...<Widget>[
                        AppCard(
                          backgroundColor: colorScheme.error.withValues(
                            alpha: 0.08,
                          ),
                          borderColor: colorScheme.error.withValues(alpha: 0.3),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.error_outline_rounded,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  alarmError,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Audio Status Banner
                      if (isSoundPaused) ...<Widget>[
                        AppCard(
                          backgroundColor: colorScheme.surfaceContainer,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.volume_off_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ringtone paused · Keep solving challenge (30s inactivity limit)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else if (wasResumedMaxDuration) ...<Widget>[
                        AppCard(
                          backgroundColor: colorScheme.error.withValues(
                            alpha: 0.08,
                          ),
                          borderColor: colorScheme.error.withValues(alpha: 0.3),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '5-minute maximum mission duration reached. Ringtone will remain active until dismissed.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else if (wasResumedInactivity) ...<Widget>[
                        AppCard(
                          backgroundColor: colorScheme.error.withValues(
                            alpha: 0.08,
                          ),
                          borderColor: colorScheme.error.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.volume_up_rounded,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Ringtone resumed due to 30s inactivity!',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.tonal(
                                  onPressed: controller.onContinueMission,
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('Continue Mission'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (controller.mission != null) ...<Widget>[
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.flag_rounded,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      controller.totalMissions > 1
                                          ? (areMissionsDone
                                                ? 'All ${controller.totalMissions} missions completed'
                                                : 'Mission ${controller.currentMissionIndex + 1} of ${controller.totalMissions}')
                                          : 'Required mission',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            letterSpacing: 0.8,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      areMissionsDone
                                          ? 'Missions complete · Tap Dismiss'
                                          : '${controller.mission!.type.label} · ${controller.mission!.difficulty.label}',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (areMissionsDone)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green.shade600,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),

                      // Action Button (Strict Alarm Mode: No Snooze button)
                      if (areMissionsDone ||
                          controller.mission == null) ...<Widget>[
                        MissionActionButton(
                          label: 'Dismiss Alarm',
                          icon: Icons.alarm_off_rounded,
                          onPressed: controller.onDismiss,
                        ),
                      ] else ...<Widget>[
                        MissionActionButton(
                          label: wasResumedInactivity
                              ? 'Continue Mission'
                              : (controller.totalMissions > 1
                                    ? 'Start Mission (${controller.currentMissionIndex + 1}/${controller.totalMissions})'
                                    : 'Start Mission'),
                          icon: Icons.play_arrow_rounded,
                          onPressed: () {
                            if (wasResumedInactivity) {
                              controller.onContinueMission();
                            } else {
                              controller.onStartMission(context);
                            }
                          },
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
