import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_dialogs.dart';
import 'package:smart_alarm/core/widgets/app_empty_state.dart';
import 'package:smart_alarm/core/widgets/app_feedback.dart';
import 'package:smart_alarm/data/models/alarm_history_record.dart';
import 'package:smart_alarm/features/history/controllers/history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm History'),
        actions: <Widget>[
          IconButton(
            icon: Obx(
              () => Icon(
                controller.newestFirst.value
                    ? Icons.south_rounded
                    : Icons.north_rounded,
              ),
            ),
            tooltip: 'Toggle sort order',
            onPressed: controller.toggleSortOrder,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear history',
            onPressed: () => _confirmClearHistory(context),
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
            child: Column(
              children: <Widget>[
                _buildFilterBar(context),
                Expanded(
                  child: Obx(() {
                    final records = controller.filteredRecords;

                    if (records.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            AppConstants.horizontalPadding,
                          ),
                          child: AppCard(
                            child: AppEmptyState(
                              icon: Icons.history_rounded,
                              title: 'No history records',
                              message:
                                  'Alarm events, mission completions, and snooze activity will appear here.',
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.horizontalPadding,
                        8,
                        AppConstants.horizontalPadding,
                        32,
                      ),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HistoryRecordCard(
                            record: record,
                            onTap: () => _showRecordDetails(context, record),
                            onDelete: () => _deleteRecord(context, record),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
        vertical: 8,
      ),
      child: Column(
        children: <Widget>[
          // Status chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              final currentStatus = controller.selectedStatus.value;
              return Row(
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('All'),
                    selected: currentStatus == null,
                    onSelected: (_) => controller.setStatusFilter(null),
                  ),
                  const SizedBox(width: 8),
                  for (final status in AlarmHistoryStatus.values) ...<Widget>[
                    ChoiceChip(
                      label: Text(status.displayName),
                      selected: currentStatus == status,
                      onSelected: (_) => controller.setStatusFilter(status),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          // Date range filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              final currentDateFilter = controller.dateFilter.value;
              return Row(
                children: <Widget>[
                  for (final filter in HistoryDateFilter.values) ...<Widget>[
                    FilterChip(
                      label: Text(filter.label),
                      selected: currentDateFilter == filter,
                      onSelected: (_) => controller.setDateFilter(filter),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, AlarmHistoryRecord record) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.sheetRadius),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        record.alarmLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusBadge(status: record.status),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Scheduled Time',
                  value: AppDateUtils.formatTime(
                    record.scheduledTime.hour,
                    record.scheduledTime.minute,
                  ),
                ),
                _DetailRow(
                  label: 'Recorded Time',
                  value:
                      '${AppDateUtils.formatFullDate(record.actualTime)} at ${AppDateUtils.formatTime(record.actualTime.hour, record.actualTime.minute)}',
                ),
                if (record.completedMissions.isNotEmpty) ...<Widget>[
                  _DetailRow(
                    label: 'Mission Completed',
                    value: record.completedMissions.join(', ').toUpperCase(),
                  ),
                  if (record.difficulty != null)
                    _DetailRow(
                      label: 'Difficulty',
                      value: record.difficulty!.toUpperCase(),
                    ),
                  _DetailRow(
                    label: 'Mission Duration',
                    value: '${record.durationSeconds} seconds',
                  ),
                ],
                _DetailRow(
                  label: 'Snoozes Used',
                  value: '${record.snoozeCount}',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteRecord(
    BuildContext context,
    AlarmHistoryRecord record,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Delete record?',
      message: 'This history entry will be permanently removed.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (!context.mounted || !confirmed) return;

    final success = await controller.deleteRecord(record.id);
    if (!context.mounted) return;

    if (success) {
      AppFeedback.success(context, 'Record deleted');
    } else {
      AppFeedback.error(context, 'Could not delete record');
    }
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Clear all history?',
      message:
          'This will permanently delete all past alarm and mission completion records. This action cannot be undone.',
      confirmLabel: 'Clear All',
      destructive: true,
    );

    if (!context.mounted || !confirmed) return;

    final success = await controller.clearAllHistory();
    if (!context.mounted) return;

    if (success) {
      AppFeedback.success(context, 'History cleared');
    } else {
      AppFeedback.error(context, 'Could not clear history');
    }
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final AlarmHistoryRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _statusColor(
                record.status,
                colorScheme,
              ).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _statusIcon(record.status),
              color: _statusColor(record.status, colorScheme),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        record.alarmLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      AppDateUtils.formatTime(
                        record.actualTime.hour,
                        record.actualTime.minute,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Text(
                      AppDateUtils.formatFullDate(record.actualTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (record.completedMissions.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 8),
                      Text(
                        '•  ${record.completedMissions.first.toUpperCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            tooltip: 'Delete record',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Color _statusColor(AlarmHistoryStatus status, ColorScheme colorScheme) {
    return switch (status) {
      AlarmHistoryStatus.completed => Colors.green.shade600,
      AlarmHistoryStatus.snoozed => Colors.orange.shade700,
      AlarmHistoryStatus.missed => colorScheme.error,
      AlarmHistoryStatus.cancelled => colorScheme.onSurfaceVariant,
    };
  }

  IconData _statusIcon(AlarmHistoryStatus status) {
    return switch (status) {
      AlarmHistoryStatus.completed => Icons.check_circle_outline_rounded,
      AlarmHistoryStatus.snoozed => Icons.snooze_rounded,
      AlarmHistoryStatus.missed => Icons.alarm_off_rounded,
      AlarmHistoryStatus.cancelled => Icons.cancel_outlined,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AlarmHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color bg;
    Color fg;

    switch (status) {
      case AlarmHistoryStatus.completed:
        bg = Colors.green.withValues(alpha: 0.12);
        fg = Colors.green.shade700;
        break;
      case AlarmHistoryStatus.snoozed:
        bg = Colors.orange.withValues(alpha: 0.12);
        fg = Colors.orange.shade800;
        break;
      case AlarmHistoryStatus.missed:
        bg = colorScheme.error.withValues(alpha: 0.12);
        fg = colorScheme.error;
        break;
      case AlarmHistoryStatus.cancelled:
        bg = colorScheme.surfaceContainer;
        fg = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
