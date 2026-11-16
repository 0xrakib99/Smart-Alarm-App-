import 'package:flutter/material.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/core/widgets/app_card.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.type,
    required this.selected,
    required this.difficulty,
    required this.onSelect,
    required this.onDifficultyChanged,
    this.onTest,
  });

  final MissionType type;
  final bool selected;
  final MissionDifficulty difficulty;
  final VoidCallback onSelect;
  final ValueChanged<MissionDifficulty> onDifficultyChanged;
  final VoidCallback? onTest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onSelect,
      backgroundColor: selected
          ? colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.035)
          : null,
      borderColor: selected ? colorScheme.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Icon(
                  _iconFor(type),
                  size: 23,
                  color: selected ? colorScheme.onPrimary : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(type.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 22,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: selected
                ? Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'DIFFICULTY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: MissionDifficulty.values
                              .map((value) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: _DifficultyPill(
                                      label: value.label,
                                      selected: value == difficulty,
                                      onTap: () => onDifficultyChanged(value),
                                    ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 12),
                        _LiveDifficultyPreview(
                          type: type,
                          difficulty: difficulty,
                        ),
                        if (onTest != null) ...<Widget>[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: onTest,
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                size: 18,
                              ),
                              label: const Text('Test challenge'),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(MissionType type) {
    return switch (type) {
      MissionType.math => Icons.calculate_rounded,
      MissionType.tap => Icons.touch_app_rounded,
      MissionType.memory => Icons.grid_view_rounded,
      MissionType.puzzle => Icons.format_list_numbered_rounded,
      MissionType.shake => Icons.vibration_rounded,
      MissionType.wordScramble => Icons.spellcheck_rounded,
      MissionType.colorSequence => Icons.palette_rounded,
      MissionType.typing => Icons.keyboard_rounded,
    };
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label difficulty',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveDifficultyPreview extends StatelessWidget {
  const _LiveDifficultyPreview({required this.type, required this.difficulty});

  final MissionType type;
  final MissionDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return switch (type) {
      MissionType.puzzle => _buildPuzzlePreview(theme, colorScheme),
      MissionType.wordScramble => _buildWordScramblePreview(theme, colorScheme),
      MissionType.colorSequence => _buildColorSequencePreview(
        theme,
        colorScheme,
      ),
      MissionType.typing => _buildTypingPreview(theme, colorScheme),
      MissionType.math => _buildMathPreview(theme, colorScheme),
      MissionType.tap => _buildTapPreview(theme, colorScheme),
      MissionType.memory => _buildMemoryPreview(theme, colorScheme),
      MissionType.shake => _buildShakePreview(theme, colorScheme),
    };
  }

  Widget _buildPuzzlePreview(ThemeData theme, ColorScheme colorScheme) {
    final size = MissionDifficultyConfig.puzzleGridSize(difficulty);
    final totalTiles = size * size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.grid_on_rounded, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$size×$size Board · ${totalTiles - 1} Numbered Tiles',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              List.generate(size.clamp(3, 5), (i) {
                return Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: 10,
                    ),
                  ),
                );
              })..add(
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    '···',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildWordScramblePreview(ThemeData theme, ColorScheme colorScheme) {
    final count = MissionDifficultyConfig.wordScrambleWordCount(difficulty);
    final lengthLabel = MissionDifficultyConfig.wordScrambleLengthLabel(
      difficulty,
    );

    final sampleLetters = switch (difficulty) {
      MissionDifficulty.easy => const <String>['W', 'A', 'K', 'E'],
      MissionDifficulty.medium => const <String>['S', 'M', 'A', 'R', 'T'],
      MissionDifficulty.hard => const <String>[
        'M',
        'O',
        'R',
        'N',
        'I',
        'N',
        'G',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.spellcheck_rounded,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$count Words · $lengthLabel each',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: sampleLetters
              .map((char) {
                return Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    char,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize: 10,
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildColorSequencePreview(ThemeData theme, ColorScheme colorScheme) {
    final len = MissionDifficultyConfig.colorSequenceLength(difficulty);
    const palette = <Color>[
      Color(0xFFE53935), // Red
      Color(0xFF1E88E5), // Blue
      Color(0xFF43A047), // Green
      Color(0xFFFB8C00), // Amber
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.palette_rounded, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$len Steps Sequence · Memory Challenge',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(len, (i) {
            final color = palette[i % palette.length];
            return Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTypingPreview(ThemeData theme, ColorScheme colorScheme) {
    final count = MissionDifficultyConfig.typingSentenceCount(difficulty);
    final wordRange = MissionDifficultyConfig.typingWordCountLabel(difficulty);

    final sampleQuote = switch (difficulty) {
      MissionDifficulty.easy => 'Early birds catch the morning sun.',
      MissionDifficulty.medium => 'Consistency is the key to morning victory.',
      MissionDifficulty.hard => 'Every sunrise brings new strength and focus.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.keyboard_rounded, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$count Sentence${count > 1 ? "s" : ""} · $wordRange',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '"$sampleQuote"',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMathPreview(ThemeData theme, ColorScheme colorScheme) {
    final count = MissionDifficultyConfig.mathQuestionCount(difficulty);
    final example = switch (difficulty) {
      MissionDifficulty.easy => '8 + 5 = ?',
      MissionDifficulty.medium => '14 × 6 - 8 = ?',
      MissionDifficulty.hard => '42 × 17 + 29 = ?',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.calculate_rounded, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$count Questions · e.g. $example',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTapPreview(ThemeData theme, ColorScheme colorScheme) {
    final count = MissionDifficultyConfig.tapTargetCount(difficulty);

    return Row(
      children: <Widget>[
        Icon(Icons.touch_app_rounded, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$count Rapid Taps Required',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryPreview(ThemeData theme, ColorScheme colorScheme) {
    final pairs = MissionDifficultyConfig.memoryPairCount(difficulty);

    return Row(
      children: <Widget>[
        Icon(Icons.grid_view_rounded, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$pairs Matching Pairs (${pairs * 2} cards)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShakePreview(ThemeData theme, ColorScheme colorScheme) {
    final count = MissionDifficultyConfig.shakeCount(difficulty);

    return Row(
      children: <Widget>[
        Icon(Icons.vibration_rounded, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$count Vigorous Shakes Required',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
