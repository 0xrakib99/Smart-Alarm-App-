import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/utils/date_time_utils.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_feedback.dart';
import 'package:smart_alarm/core/widgets/app_primary_button.dart';
import 'package:smart_alarm/core/widgets/app_section_header.dart';
import 'package:smart_alarm/core/widgets/app_setting_row.dart';
import 'package:smart_alarm/core/widgets/app_settings_group.dart';
import 'package:smart_alarm/core/widgets/weekday_selector.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/alarm/controllers/create_alarm_controller.dart';
import 'package:smart_alarm/features/alarm/presentation/widgets/alarm_time_card.dart';
import 'package:smart_alarm/features/alarm/presentation/widgets/sound_selection_sheet.dart';

class CreateAlarmScreen extends GetView<CreateAlarmController> {
  const CreateAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit alarm' : 'New alarm'),
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
              final daysSummary = AppDateUtils.daysSummary(
                controller.repeatDays,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  8,
                  AppConstants.horizontalPadding,
                  24,
                ),
                children: <Widget>[
                  AlarmTimeCard(
                    hour: controller.time.value.hour,
                    minute: controller.time.value.minute,
                    onTap: () => _pickTime(context),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.labelController,
                    maxLength: AppConstants.maxAlarmLabelLength,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Alarm label',
                      hintText: 'Wake up',
                      prefixIcon: Icon(Icons.edit_outlined),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 26),
                  AppSectionHeader(
                    title: 'Repeat',
                    trailing: Text(
                      daysSummary,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: WeekdaySelector(
                      selectedDays: controller.selectedDays,
                      onDayToggled: controller.toggleDay,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const AppSectionHeader(title: 'Alarm settings'),
                  AppSettingsGroup(
                    children: <Widget>[
                      AppSettingRow(
                        icon: Icons.music_note_rounded,
                        title: 'Alarm sound',
                        subtitle: controller.soundName,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (controller.isCustomSound)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Custom',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.outlineVariant,
                            ),
                          ],
                        ),
                        onTap: () => _pickSound(context),
                      ),
                      AppSettingRow(
                        icon: Icons.vibration_rounded,
                        title: 'Vibration',
                        subtitle: 'Vibrate while the alarm rings',
                        trailing: Switch(
                          value: controller.vibrationEnabled.value,
                          onChanged: controller.setVibrationEnabled,
                        ),
                      ),
                      AppSettingRow(
                        icon: Icons.snooze_rounded,
                        title: 'Snooze',
                        subtitle: controller.snoozeEnabled.value
                            ? '${controller.snoozeMinutes.value} minutes '
                                  'after the alarm'
                            : 'Snooze is turned off',
                        trailing: Switch(
                          value: controller.snoozeEnabled.value,
                          onChanged: controller.setSnoozeEnabled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const AppSectionHeader(title: 'Mission'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: AppSettingRow(
                      icon: Icons.flag_outlined,
                      title: 'Wake-up mission',
                      subtitle: controller.missions.isEmpty
                          ? 'Choose a mission'
                          : controller.missions.length == 1
                          ? '${controller.missions.first.type.label} · '
                                '${controller.missions.first.difficulty.label}'
                          : '${controller.missions.length} missions (${controller.missions.map((m) => m.type.label).join(", ")})',
                      onTap: () => _openMissions(context),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveBar(context),
    );
  }

  Widget _buildSaveBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.horizontalPadding,
            12,
            AppConstants.horizontalPadding,
            12,
          ),
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.pageMaxWidth,
              ),
              child: Obx(
                () => AppPrimaryButton(
                  label: controller.isEditing ? 'Save changes' : 'Create alarm',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.isSaving.value
                      ? null
                      : () => _save(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.time.value,
      helpText: 'Select alarm time',
    );
    if (picked != null) {
      controller.setTime(picked);
    }
  }

  Future<void> _pickSound(BuildContext context) async {
    final result = await SoundSelectionSheet.show(
      context,
      currentSoundId: controller.soundId.value,
      currentCustomPath: controller.customSoundPath.value,
      currentCustomName: controller.customSoundName.value,
    );

    if (result != null) {
      controller.setSoundSelection(
        id: result.soundId,
        customPath: result.customSoundPath,
        customName: result.customSoundName,
      );
    }
  }

  Future<void> _openMissions(BuildContext context) async {
    final currentSelection = controller.missions.isNotEmpty
        ? controller.missions.toList()
        : null;
    final routeFuture = Get.toNamed(
      AppRoutes.missions,
      arguments: currentSelection,
    );
    final selection = routeFuture == null ? null : await routeFuture;

    if (!context.mounted || selection == null) {
      return;
    }
    if (selection is List<MissionConfig>) {
      controller.setMissions(selection);
    } else if (selection is MissionConfig) {
      controller.setMissions([selection]);
    }
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.save();
    if (!context.mounted) {
      return;
    }

    if (saved) {
      final warning = controller.scheduleWarning.value;
      if (warning != null) {
        AppFeedback.error(context, warning);
      }
      Get.back(result: warning == null);
    } else {
      AppFeedback.error(context, 'Could not save the alarm. Please try again.');
    }
  }
}
