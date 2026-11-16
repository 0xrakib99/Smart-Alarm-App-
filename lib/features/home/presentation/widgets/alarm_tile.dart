import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/data/models/alarm_model.dart';
import 'package:smart_alarm/data/models/mission_config.dart';

enum _AlarmAction { edit, delete }

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = alarm.label.trim().isEmpty
        ? AppConstants.defaultAlarmLabel
        : alarm.label;
    final missionText = alarm.missions.isEmpty
        ? 'No mission'
        : alarm.missions.length == 1
        ? '${alarm.missions.first.type.label} · ${alarm.missions.first.difficulty.label}'
        : '${alarm.missions.length} missions';

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 12),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: alarm.enabled ? 1 : 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppDateUtils.formatTime(alarm.hour, alarm.minute),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Switch(value: alarm.enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: alarm.enabled ? 1 : 0.55,
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: <Widget>[
                      _AlarmMeta(
                        icon: Icons.repeat_rounded,
                        text: AppDateUtils.daysSummary(alarm.repeatDays),
                      ),
                      _AlarmMeta(icon: Icons.bolt_rounded, text: missionText),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<_AlarmAction>(
                tooltip: 'Alarm options',
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _AlarmAction.edit:
                      onEdit();
                      break;
                    case _AlarmAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<_AlarmAction>>[
                  const PopupMenuItem<_AlarmAction>(
                    value: _AlarmAction.edit,
                    child: _MenuItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit alarm',
                    ),
                  ),
                  PopupMenuItem<_AlarmAction>(
                    value: _AlarmAction.delete,
                    child: _MenuItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete alarm',
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlarmMeta extends StatelessWidget {
  const _AlarmMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: effectiveColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: effectiveColor)),
      ],
    );
  }
}
