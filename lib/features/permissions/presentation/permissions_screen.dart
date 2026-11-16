import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/services/permission_service.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_section_header.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final permService = Get.find<PermissionService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions & Reliability')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.pageMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding,
                8,
                AppConstants.horizontalPadding,
                32,
              ),
              children: <Widget>[
                Text(
                  'Smart Alarm requires specific Android permissions to guarantee that your alarms ring precisely on time, even when your phone is locked or in deep battery sleep (Doze mode).',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                const AppSectionHeader(title: 'Essential permissions'),
                const SizedBox(height: 10),
                Obx(() {
                  final isGranted = permService.exactAlarmGranted.value;
                  return _PermissionTile(
                    icon: Icons.alarm_rounded,
                    title: 'Exact Alarm Scheduling',
                    statusText: isGranted ? 'Granted' : 'Action Required',
                    isGranted: isGranted,
                    description:
                        'Allows alarms to fire at the exact second you set, bypassing Android Doze mode and power saving restrictions.',
                    actionLabel: isGranted ? null : 'Enable in Settings',
                    onAction: isGranted
                        ? null
                        : () => permService.requestExactAlarmPermission(),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  final isGranted = permService.notificationGranted.value;
                  return _PermissionTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    statusText: isGranted ? 'Granted' : 'Action Required',
                    isGranted: isGranted,
                    description:
                        'Required by Android 13+ to display the ringing alarm, lock screen notification, and foreground controls.',
                    actionLabel: isGranted ? null : 'Allow Notifications',
                    onAction: isGranted
                        ? null
                        : () => permService.requestNotificationPermission(),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  final isGranted = permService.fullScreenIntentGranted.value;
                  return _PermissionTile(
                    icon: Icons.fullscreen_rounded,
                    title: 'Full-Screen Intent',
                    statusText: isGranted ? 'Active' : 'Recommended',
                    isGranted: isGranted,
                    description:
                        'Allows the alarm and mission interface to display over the lock screen immediately when the alarm triggers.',
                    actionLabel: isGranted ? null : 'Enable in Settings',
                    onAction: isGranted
                        ? null
                        : () => permService.requestFullScreenIntentPermission(),
                  );
                }),
                const SizedBox(height: 28),
                const AppSectionHeader(title: 'Hardware & capabilities'),
                const SizedBox(height: 10),
                const _PermissionTile(
                  icon: Icons.screen_rotation_rounded,
                  title: 'Device Motion & Sensors',
                  statusText: 'Available',
                  isGranted: true,
                  description:
                      'Used for the Shake mission to detect real device movement with noise suppression and anti-cheat thresholds.',
                ),
                const SizedBox(height: 12),
                const _PermissionTile(
                  icon: Icons.vibration_rounded,
                  title: 'Vibration Motor',
                  statusText: 'Available',
                  isGranted: true,
                  description:
                      'Provides high-priority tactile wake-up pulses alongside alarm audio.',
                ),
                const SizedBox(height: 28),
                AppCard(
                  backgroundColor: colorScheme.surfaceContainer,
                  borderColor: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Privacy Notice: Smart Alarm never requests camera, contacts, microphone, or location permissions. All alarm and game logic runs 100% locally on your device.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.statusText,
    required this.isGranted,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String statusText;
  final bool isGranted;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isGranted
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isGranted ? colorScheme.primary : colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Icon(
                          isGranted
                              ? Icons.check_circle_rounded
                              : Icons.warning_rounded,
                          size: 14,
                          color: isGranted
                              ? Colors.green.shade600
                              : colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isGranted
                                ? Colors.green.shade600
                                : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
