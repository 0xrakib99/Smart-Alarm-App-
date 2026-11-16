import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';

class AppPickerOption<T> {
  const AppPickerOption({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

Future<T?> showAppPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppPickerOption<T>> options,
  T? selectedValue,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colorScheme = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.68,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.sheetRadius),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 10, 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded, size: 22),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = option.value == selectedValue;

                    return Material(
                      color: selected
                          ? colorScheme.primary.withValues(
                              alpha: isDark ? 0.18 : 0.06,
                            )
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallRadius,
                        ),
                        onTap: () =>
                            Navigator.of(sheetContext).pop(option.value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      option.label,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    if (option.subtitle != null) ...<Widget>[
                                      const SizedBox(height: 2),
                                      Text(
                                        option.subtitle!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 22,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
