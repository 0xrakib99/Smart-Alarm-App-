import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/widgets/app_primary_button.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/controllers/mission_selection_controller.dart';
import 'package:smart_alarm/features/missions/presentation/widgets/mission_card.dart';

class MissionSelectionScreen extends GetView<MissionSelectionController> {
  const MissionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Wake-up mission')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.pageMaxWidth,
            ),
            child: Obx(() {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  8,
                  AppConstants.horizontalPadding,
                  24,
                ),
                children: <Widget>[
                  Text(
                    'Select one or more challenges required to dismiss the alarm, '
                    'and set independent difficulty for each.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final type in MissionType.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MissionCard(
                        type: type,
                        selected: controller.isSelected(type),
                        difficulty: controller.getDifficulty(type),
                        onSelect: () => controller.toggleMission(type),
                        onDifficultyChanged: (diff) =>
                            controller.setMissionDifficulty(type, diff),
                        onTest: () => controller.testMission(
                          type,
                          controller.getDifficulty(type),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: _buildApplyBar(context),
    );
  }

  Widget _buildApplyBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              child: Obx(() {
                final count = controller.selectedCount;
                final buttonLabel = count > 1
                    ? 'Use $count missions'
                    : 'Use mission';

                return Row(
                  children: <Widget>[
                    if (controller.hasSelection) ...<Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.testMission(),
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('Test'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.buttonRadius,
                              ),
                            ),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: buttonLabel,
                        icon: Icons.check_rounded,
                        onPressed: controller.hasSelection
                            ? _applySelection
                            : null,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _applySelection() {
    final selections = controller.selections;
    if (selections.isNotEmpty) {
      Get.back(result: selections);
    }
  }
}
