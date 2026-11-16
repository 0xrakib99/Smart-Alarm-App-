import 'package:flutter/material.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';

class TypingSentenceViewer extends StatelessWidget {
  const TypingSentenceViewer({
    super.key,
    required this.targetSentence,
    required this.typedText,
  });

  final String targetSentence;
  final String typedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final targetChars = targetSentence.split('');
    final typedChars = typedText.split('');

    final textSpans = <TextSpan>[];

    for (int i = 0; i < targetChars.length; i++) {
      final char = targetChars[i];
      if (i < typedChars.length) {
        final isMatch = typedChars[i] == char;
        textSpans.add(
          TextSpan(
            text: char,
            style: TextStyle(
              color: isMatch ? const Color(0xFF2E7D32) : colorScheme.error,
              backgroundColor: isMatch
                  ? Colors.transparent
                  : colorScheme.error.withValues(alpha: 0.15),
              fontWeight: FontWeight.w600,
              decoration: isMatch ? null : TextDecoration.underline,
            ),
          ),
        );
      } else if (i == typedChars.length) {
        // Next character cursor
        textSpans.add(
          TextSpan(
            text: char,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
        );
      } else {
        // Remaining unentered characters
        textSpans.add(
          TextSpan(
            text: char,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'TARGET SENTENCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${typedText.length}/${targetSentence.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText.rich(
            TextSpan(children: textSpans),
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
