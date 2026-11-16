import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_exit_confirmation.dart';

class MissionAlarmBanner extends StatelessWidget {
  const MissionAlarmBanner({super.key});

  static Future<void> handleExit(BuildContext context) async {
    final shouldExit = await MissionExitConfirmation.show(context);
    if (shouldExit) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AlarmStateService>()) {
      return const SizedBox.shrink();
    }

    final alarmState = Get.find<AlarmStateService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (alarmState.activeAlarm.value == null ||
          alarmState.currentState.value == AlarmState.idle) {
        return const SizedBox.shrink();
      }

      if (alarmState.wasSoundResumedDueToMaxDuration.value) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: colorScheme.error.withValues(alpha: 0.08),
            borderColor: colorScheme.error.withValues(alpha: 0.3),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Maximum mission duration reached. Ringtone will stay active until dismissed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (alarmState.wasSoundResumedDueToInactivity.value) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: colorScheme.error.withValues(alpha: 0.08),
            borderColor: colorScheme.error.withValues(alpha: 0.3),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.volume_up_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ringtone resumed due to inactivity.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: alarmState.continueMission,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Continue Mission'),
                ),
              ],
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
