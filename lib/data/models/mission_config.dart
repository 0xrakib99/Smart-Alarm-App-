enum MissionType {
  math,
  tap,
  memory,
  puzzle,
  shake,
  wordScramble,
  colorSequence,
  typing,
}

extension MissionTypeDetails on MissionType {
  String get label {
    return switch (this) {
      MissionType.math => 'Math Challenge',
      MissionType.tap => 'Tap Challenge',
      MissionType.memory => 'Memory Match',
      MissionType.puzzle => 'Number Puzzle',
      MissionType.shake => 'Shake Challenge',
      MissionType.wordScramble => 'Word Scramble',
      MissionType.colorSequence => 'Color Sequence',
      MissionType.typing => 'Typing Challenge',
    };
  }

  String get description {
    return switch (this) {
      MissionType.math => 'Solve arithmetic problems to stop the alarm.',
      MissionType.tap => 'Follow the targets in the right order.',
      MissionType.memory => 'Match every pair before the alarm stops.',
      MissionType.puzzle =>
        'Slide tiles into order from 1 to N with one empty space.',
      MissionType.shake => 'Shake the device until the progress is complete.',
      MissionType.wordScramble =>
        'Rearrange scrambled letters to form the correct English word.',
      MissionType.colorSequence =>
        'Memorize and repeat the glowing color sequence round by round.',
      MissionType.typing =>
        'Type the displayed morning sentence with accurate keystrokes.',
    };
  }
}

enum MissionDifficulty { easy, medium, hard }

extension MissionDifficultyDetails on MissionDifficulty {
  String get label {
    return switch (this) {
      MissionDifficulty.easy => 'Easy',
      MissionDifficulty.medium => 'Medium',
      MissionDifficulty.hard => 'Hard',
    };
  }
}

class MissionConfig {
  const MissionConfig({required this.type, required this.difficulty});

  final MissionType type;
  final MissionDifficulty difficulty;

  MissionConfig copyWith({MissionType? type, MissionDifficulty? difficulty}) {
    return MissionConfig(
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': type.name, 'difficulty': difficulty.name};
  }

  factory MissionConfig.fromMap(Map<dynamic, dynamic> map) {
    return MissionConfig(
      type: _missionTypeFromName(map['type']),
      difficulty: _difficultyFromName(map['difficulty']),
    );
  }

  static MissionType _missionTypeFromName(dynamic name) {
    if (name == 'numberPuzzle') return MissionType.puzzle;
    return MissionType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => MissionType.math,
    );
  }

  static MissionDifficulty _difficultyFromName(dynamic name) {
    return MissionDifficulty.values.firstWhere(
      (value) => value.name == name,
      orElse: () => MissionDifficulty.easy,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MissionConfig &&
        other.type == type &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode => Object.hash(type, difficulty);
}
