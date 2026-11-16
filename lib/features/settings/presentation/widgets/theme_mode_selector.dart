import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/data/models/app_settings.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ThemePreference selected;
  final ValueChanged<ThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ThemePreference.values
          .map((preference) {
            final isSelected = preference == selected;

            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label: '${_labelFor(preference)} appearance',
                child: InkWell(
                  onTap: () => onChanged(preference),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          _iconFor(preference),
                          size: 20,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _labelFor(preference),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  String _labelFor(ThemePreference preference) {
    return switch (preference) {
      ThemePreference.light => 'Light',
      ThemePreference.dark => 'Dark',
      ThemePreference.system => 'System',
    };
  }

  IconData _iconFor(ThemePreference preference) {
    return switch (preference) {
      ThemePreference.light => Icons.light_mode_outlined,
      ThemePreference.dark => Icons.dark_mode_outlined,
      ThemePreference.system => Icons.brightness_auto_outlined,
    };
  }
}
