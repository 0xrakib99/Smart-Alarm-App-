import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/services/permission_service.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_dialogs.dart';
import 'package:smart_alarm/core/widgets/app_empty_state.dart';
import 'package:smart_alarm/core/widgets/app_feedback.dart';
import 'package:smart_alarm/core/widgets/app_section_header.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/features/home/controllers/home_controller.dart';
import 'package:smart_alarm/features/home/presentation/widgets/alarm_tile.dart';
import 'package:smart_alarm/features/home/presentation/widgets/next_alarm_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.alarm_rounded,
                size: 19,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.statistics),
            tooltip: 'Statistics & Analytics',
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.history),
            tooltip: 'Alarm History',
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.settings),
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.pageMaxWidth,
            ),
            child: Obx(() {
              final alarms = controller.alarms;
              final nextAlarm = controller.nextAlarm;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  4,
                  AppConstants.horizontalPadding,
                  120,
                ),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppDateUtils.formatFullDate(controller.now),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (Get.isRegistered<PermissionService>()) ...<Widget>[
                    Obx(() {
                      final perm = Get.find<PermissionService>();
                      if (perm.hasAllRequiredPermissions) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          borderColor: colorScheme.error.withValues(alpha: 0.4),
                          backgroundColor: colorScheme.error.withValues(
                            alpha: 0.06,
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.error,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  !perm.exactAlarmGranted.value
                                      ? 'Exact alarm permission required for reliable wake-up.'
                                      : 'Notification permission required to display alarms.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.permissions),
                                child: const Text('Review'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 22),
                  const AppSectionHeader(title: 'Next alarm'),
                  NextAlarmCard(
                    nextAlarm: nextAlarm,
                    now: controller.now,
                    hasAlarms: alarms.isNotEmpty,
                    onTap: nextAlarm == null
                        ? null
                        : () => _openAlarmForm(context, alarm: nextAlarm.alarm),
                  ),
                  const SizedBox(height: 28),
                  AppSectionHeader(
                    title: 'Your alarms',
                    trailing: alarms.isEmpty
                        ? null
                        : _AlarmCountBadge(count: alarms.length),
                  ),
                  if (alarms.isEmpty)
                    const AppCard(
                      child: AppEmptyState(
                        icon: Icons.alarm_add_rounded,
                        title: 'No alarms yet',
                        message:
                            'Create your first alarm to schedule your next '
                            'wake-up.',
                      ),
                    )
                  else
                    for (final alarm in alarms)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AlarmTile(
                          alarm: alarm,
                          onToggle: (enabled) =>
                              _toggleAlarm(context, alarm, enabled),
                          onEdit: () => _openAlarmForm(context, alarm: alarm),
                          onDelete: () => _deleteAlarm(context, alarm),
                        ),
                      ),
                ],
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAlarmForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New alarm'),
      ),
    );
  }

  Future<void> _openAlarmForm(BuildContext context, {AlarmModel? alarm}) async {
    final routeFuture = Get.toNamed(AppRoutes.createAlarm, arguments: alarm);
    final saved = routeFuture == null ? null : await routeFuture;

    if (!context.mounted || saved != true) {
      return;
    }

    controller.reloadAlarms();
    AppFeedback.success(
      context,
      alarm == null ? 'Alarm saved' : 'Alarm updated',
    );
  }

  Future<void> _toggleAlarm(
    BuildContext context,
    AlarmModel alarm,
    bool enabled,
  ) async {
    final success = await controller.setAlarmEnabled(alarm.id, enabled);
    if (!context.mounted || success) {
      return;
    }
    AppFeedback.error(context, 'Could not update the alarm. Try again.');
  }

  Future<void> _deleteAlarm(BuildContext context, AlarmModel alarm) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Delete alarm?',
      message:
          'This alarm will be removed from your list. This action cannot be '
          'undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (!context.mounted || !confirmed) {
      return;
    }

    final deleted = await controller.deleteAlarm(alarm.id);
    if (!context.mounted) {
      return;
    }
    if (deleted) {
      AppFeedback.success(context, 'Alarm deleted');
    } else {
      AppFeedback.error(context, 'Could not delete the alarm. Try again.');
    }
  }
}

class _AlarmCountBadge extends StatelessWidget {
  const _AlarmCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
      ),
      child: Text(
        '$count ${count == 1 ? 'alarm' : 'alarms'}',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
