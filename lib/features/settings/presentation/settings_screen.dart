import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/constants/app_sounds.dart';
import 'package:smart_alarm/core/services/alarm_native_service.dart';
import 'package:smart_alarm/core/services/backup_service.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/core/widgets/app_dialogs.dart';
import 'package:smart_alarm/core/widgets/app_feedback.dart';
import 'package:smart_alarm/core/widgets/app_picker_sheet.dart';
import 'package:smart_alarm/core/widgets/app_section_header.dart';
import 'package:smart_alarm/core/widgets/app_setting_row.dart';
import 'package:smart_alarm/core/widgets/app_settings_group.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/data/repositories/alarm_repository.dart';
import 'package:smart_alarm/features/home/controllers/home_controller.dart';
import 'package:smart_alarm/features/settings/controllers/settings_controller.dart';
import 'package:smart_alarm/features/settings/presentation/widgets/theme_mode_selector.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.pageMaxWidth,
            ),
            child: Obx(() {
              final settings = controller.settings;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  8,
                  AppConstants.horizontalPadding,
                  32,
                ),
                children: <Widget>[
                  // 1. Appearance
                  const AppSectionHeader(title: 'Appearance'),
                  AppCard(
                    padding: const EdgeInsets.all(6),
                    child: ThemeModeSelector(
                      selected: settings.themePreference,
                      onChanged: (preference) => _applySetting(
                        context,
                        () => controller.setThemePreference(preference),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. Alarm defaults
                  const AppSectionHeader(title: 'Alarm defaults'),
                  Text(
                    'Applied when creating new alarms.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppSettingsGroup(
                    children: <Widget>[
                      AppSettingRow(
                        icon: Icons.music_note_rounded,
                        title: 'Alarm sound',
                        subtitle: AppSounds.nameFor(settings.alarmSoundId),
                        onTap: () => _pickSound(context),
                      ),
                      AppSettingRow(
                        icon: Icons.volume_up_rounded,
                        title: 'Alarm volume',
                        subtitle: '${settings.alarmVolume}%',
                        onTap: () => _pickAlarmVolume(context),
                      ),
                      AppSettingRow(
                        icon: Icons.vibration_rounded,
                        title: 'Vibration',
                        subtitle: 'Vibrate when an alarm rings',
                        trailing: Switch(
                          value: settings.vibrationEnabled,
                          onChanged: (value) => _applySetting(
                            context,
                            () => controller.setVibrationEnabled(value),
                          ),
                        ),
                      ),
                      AppSettingRow(
                        icon: Icons.snooze_rounded,
                        title: 'Snooze',
                        subtitle: 'Allow extra time before the mission',
                        trailing: Switch(
                          value: settings.snoozeEnabled,
                          onChanged: (value) => _applySetting(
                            context,
                            () => controller.setSnoozeEnabled(value),
                          ),
                        ),
                      ),
                      if (settings.snoozeEnabled) ...<Widget>[
                        AppSettingRow(
                          icon: Icons.timer_outlined,
                          title: 'Snooze duration',
                          subtitle: '${settings.snoozeMinutes} minutes',
                          onTap: () => _pickSnoozeDuration(context),
                        ),
                        AppSettingRow(
                          icon: Icons.repeat_rounded,
                          title: 'Maximum snoozes',
                          subtitle: '${settings.maxSnoozeCount} times',
                          onTap: () => _pickMaxSnoozes(context),
                        ),
                      ],
                      AppSettingRow(
                        icon: Icons.military_tech_rounded,
                        title: 'Default mission difficulty',
                        subtitle: settings.defaultDifficulty.label,
                        onTap: () => _pickDefaultDifficulty(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 3. Analytics & History
                  const AppSectionHeader(title: 'Data & records'),
                  AppSettingsGroup(
                    children: <Widget>[
                      AppSettingRow(
                        icon: Icons.insights_rounded,
                        title: 'Statistics & trends',
                        subtitle: 'Streaks, average wake-up time, and activity',
                        onTap: () => Get.toNamed(AppRoutes.statistics),
                      ),
                      AppSettingRow(
                        icon: Icons.history_rounded,
                        title: 'Alarm history',
                        subtitle: 'Past alarms, completion status, and logs',
                        onTap: () => Get.toNamed(AppRoutes.history),
                      ),
                      AppSettingRow(
                        icon: Icons.file_download_outlined,
                        title: 'Export backup',
                        subtitle: 'Save alarms, settings, and history as JSON',
                        onTap: () => _handleExportBackup(context),
                      ),
                      AppSettingRow(
                        icon: Icons.file_upload_outlined,
                        title: 'Import backup',
                        subtitle: 'Restore alarms and history from JSON text',
                        onTap: () => _handleImportBackup(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 4. System & Permissions
                  const AppSectionHeader(title: 'System & reliability'),
                  AppSettingsGroup(
                    children: <Widget>[
                      AppSettingRow(
                        icon: Icons.security_rounded,
                        title: 'Permissions & background access',
                        subtitle:
                            'Exact alarm, notifications & lock-screen intent',
                        onTap: () => Get.toNamed(AppRoutes.permissions),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 5. App information
                  const AppSectionHeader(title: 'App information'),
                  AppSettingsGroup(
                    children: <Widget>[
                      AppSettingRow(
                        icon: Icons.info_outline_rounded,
                        title: 'About Smart Alarm',
                        subtitle: 'Version ${AppConstants.appVersion}',
                        onTap: () => showAppInfoDialog(context),
                      ),
                      AppSettingRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy & local data',
                        subtitle: 'All data stays exclusively on this device',
                        onTap: () => _showPrivacyDialog(context),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _applySetting(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final saved = await action();
    if (!context.mounted) {
      return;
    }
    if (!saved) {
      AppFeedback.error(
        context,
        'Could not save this setting. Please try again.',
      );
    }
  }

  Future<void> _pickSound(BuildContext context) async {
    final selected = await showAppPickerSheet<String>(
      context: context,
      title: 'Alarm sound',
      selectedValue: controller.settings.alarmSoundId,
      options: AppSounds.all
          .map(
            (sound) =>
                AppPickerOption<String>(value: sound.id, label: sound.name),
          )
          .toList(growable: false),
    );

    if (!context.mounted || selected == null) return;
    await _applySetting(
      context,
      () => controller.setDefaultAlarmSound(selected),
    );
  }

  Future<void> _pickAlarmVolume(BuildContext context) async {
    const volumeOptions = <int>[20, 40, 60, 80, 100];
    final selected = await showAppPickerSheet<int>(
      context: context,
      title: 'Alarm volume',
      selectedValue: controller.settings.alarmVolume,
      options: volumeOptions
          .map((v) => AppPickerOption<int>(value: v, label: '$v%'))
          .toList(growable: false),
    );

    if (!context.mounted || selected == null) return;
    await _applySetting(context, () => controller.setAlarmVolume(selected));
    if (Get.isRegistered<AlarmNativeService>() &&
        Get.isRegistered<AlarmRepository>()) {
      await Get.find<AlarmNativeService>().syncAlarms(
        Get.find<AlarmRepository>().getAlarms(),
      );
    }
  }

  Future<void> _pickSnoozeDuration(BuildContext context) async {
    final selected = await showAppPickerSheet<int>(
      context: context,
      title: 'Snooze duration',
      selectedValue: controller.settings.snoozeMinutes,
      options: AppConstants.snoozeOptions
          .map(
            (minutes) =>
                AppPickerOption<int>(value: minutes, label: '$minutes minutes'),
          )
          .toList(growable: false),
    );

    if (!context.mounted || selected == null) return;
    await _applySetting(context, () => controller.setSnoozeMinutes(selected));
  }

  Future<void> _pickMaxSnoozes(BuildContext context) async {
    final selected = await showAppPickerSheet<int>(
      context: context,
      title: 'Maximum snoozes',
      selectedValue: controller.settings.maxSnoozeCount,
      options: const <int>[1, 2, 3, 5]
          .map(
            (count) =>
                AppPickerOption<int>(value: count, label: '$count times'),
          )
          .toList(growable: false),
    );

    if (!context.mounted || selected == null) return;
    await _applySetting(context, () => controller.setMaxSnoozeCount(selected));
  }

  Future<void> _pickDefaultDifficulty(BuildContext context) async {
    final selected = await showAppPickerSheet<MissionDifficulty>(
      context: context,
      title: 'Default challenge difficulty',
      selectedValue: controller.settings.defaultDifficulty,
      options: MissionDifficulty.values
          .map(
            (d) => AppPickerOption<MissionDifficulty>(value: d, label: d.label),
          )
          .toList(growable: false),
    );

    if (!context.mounted || selected == null) return;
    await _applySetting(
      context,
      () => controller.setDefaultDifficulty(selected),
    );
  }

  Future<void> _handleExportBackup(BuildContext context) async {
    if (!Get.isRegistered<BackupService>()) return;
    final backupService = Get.find<BackupService>();
    final jsonText = await backupService.exportBackupJson();

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Export Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Copy this JSON backup text to store or transfer your alarms and history.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                height: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy to Clipboard'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: jsonText));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  AppFeedback.success(context, 'Backup copied to clipboard');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleImportBackup(BuildContext context) async {
    if (!Get.isRegistered<BackupService>()) return;

    final backupJson = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _ImportBackupDialog(),
    );

    if (backupJson == null || !context.mounted) return;

    final backupService = Get.find<BackupService>();
    final result = await backupService.importBackupJson(backupJson);

    if (result.success) {
      controller.onInit();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().reloadAlarms();
      }
      if (Get.isRegistered<AlarmNativeService>() &&
          Get.isRegistered<AlarmRepository>()) {
        await Get.find<AlarmNativeService>().syncAlarms(
          Get.find<AlarmRepository>().getAlarms(),
        );
      }
    }

    if (!context.mounted) return;

    if (result.success) {
      AppFeedback.success(
        context,
        'Imported ${result.alarmsImported} alarms and ${result.historyImported} history records.',
      );
    } else {
      AppFeedback.error(
        context,
        result.errorMessage ?? 'Could not import backup.',
      );
    }
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Privacy & Data Local Storage'),
          content: Text(
            'Smart Alarm operates on a 100% offline-first architecture. All alarm configurations, mission completion data, and statistics are stored locally on your device using encrypted, sandboxed storage.\n\nNo accounts, telemetry, cloud servers, or third-party trackers are utilized.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }
}

class _ImportBackupDialog extends StatefulWidget {
  const _ImportBackupDialog();

  @override
  State<_ImportBackupDialog> createState() => _ImportBackupDialogState();
}

class _ImportBackupDialogState extends State<_ImportBackupDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Import Backup'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Paste your exported JSON backup text below to restore alarms and history records.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '{\n  "schemaVersion": 1, ...\n}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Restore Data'),
        ),
      ],
    );
  }
}
