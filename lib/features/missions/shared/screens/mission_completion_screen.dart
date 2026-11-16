import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/shared/widgets/mission_action_button.dart';

class MissionCompletionScreen extends StatelessWidget {
  const MissionCompletionScreen({
    super.key,
    required this.result,
    this.onDismiss,
  });

  final MissionResult result;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _finish();
        }
      },
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
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 52,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mission completed',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.type.label} (${result.difficulty.label}) solved successfully.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          _buildStatRow(
                            context,
                            icon: Icons.timer_outlined,
                            label: 'Time elapsed',
                            value: result.formattedDuration,
                          ),
                          if (result.moves > 0) ...<Widget>[
                            const Divider(height: 24),
                            _buildStatRow(
                              context,
                              icon: Icons.swap_horiz_rounded,
                              label: 'Moves',
                              value: '${result.moves}',
                            ),
                          ],
                          if (result.attempts > 0) ...<Widget>[
                            const Divider(height: 24),
                            _buildStatRow(
                              context,
                              icon: Icons.ads_click_rounded,
                              label: 'Total attempts',
                              value: '${result.attempts}',
                            ),
                          ],
                          if (result.metrics.isNotEmpty) ...<Widget>[
                            for (final entry
                                in result.metrics.entries) ...<Widget>[
                              const Divider(height: 24),
                              _buildStatRow(
                                context,
                                icon: Icons.insights_outlined,
                                label: entry.key,
                                value: entry.value.toString(),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    MissionActionButton(
                      label: onDismiss != null
                          ? 'Dismiss Alarm'
                          : 'Complete mission',
                      icon: onDismiss != null
                          ? Icons.alarm_off_rounded
                          : Icons.check_rounded,
                      onPressed: _finish,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _finish() {
    if (onDismiss != null) {
      onDismiss!();
    } else {
      Get.back(result: result);
    }
  }
}
