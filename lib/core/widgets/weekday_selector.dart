import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  final Set<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  static const List<String> _labels = <String>[
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  static const List<String> _names = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: List<Widget>.generate(7, (index) {
        final day = index + 1;
        final selected = selectedDays.contains(day);

        return Expanded(
          child: Semantics(
            button: true,
            selected: selected,
            label: _names[index],
            onTap: () => onDayToggled(day),
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onDayToggled(day),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      _labels[index],
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
