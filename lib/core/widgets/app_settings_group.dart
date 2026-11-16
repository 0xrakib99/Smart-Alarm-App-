import 'package:flutter/material.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';

class AppSettingsGroup extends StatelessWidget {
  const AppSettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (var index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0)
              Divider(height: 1, thickness: 1, indent: 68, color: borderColor),
            children[index],
          ],
        ],
      ),
    );
  }
}
