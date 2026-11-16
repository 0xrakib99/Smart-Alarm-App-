import 'package:smart_alarm/data/models/mission_config.dart';

abstract final class MissionDifficultyConfig {
  // --- Math Mission ---
  static int mathQuestionCount(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 3,
      MissionDifficulty.medium => 5,
      MissionDifficulty.hard => 7,
    };
  }

  // --- Tap Mission ---
  static int tapTargetCount(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 10,
      MissionDifficulty.medium => 15,
      MissionDifficulty.hard => 20,
    };
  }

  static Duration tapTargetDuration(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => const Duration(milliseconds: 2600),
      MissionDifficulty.medium => const Duration(milliseconds: 1800),
      MissionDifficulty.hard => const Duration(milliseconds: 1200),
    };
  }

  static double tapTargetSize(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 68.0,
      MissionDifficulty.medium => 58.0,
      MissionDifficulty.hard => 48.0,
    };
  }

  // --- Memory Match Mission ---
  static int memoryPairCount(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 2,
      MissionDifficulty.medium => 4,
      MissionDifficulty.hard => 6,
    };
  }

  static int memoryGridColumns(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 2,
      MissionDifficulty.medium => 2,
      MissionDifficulty.hard => 3,
    };
  }

  static Duration memoryPeekDelay(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => const Duration(milliseconds: 900),
      MissionDifficulty.medium => const Duration(milliseconds: 750),
      MissionDifficulty.hard => const Duration(milliseconds: 600),
    };
  }

  // --- Puzzle Mission ---
  static int puzzleGridSize(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 3, // 3x3
      MissionDifficulty.medium => 4, // 4x4
      MissionDifficulty.hard => 5, // 5x5
    };
  }

  static int puzzleShuffleMoves(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 30,
      MissionDifficulty.medium => 60,
      MissionDifficulty.hard => 100,
    };
  }

  // --- Shake Mission ---
  static int shakeCount(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 20,
      MissionDifficulty.medium => 40,
      MissionDifficulty.hard => 60,
    };
  }

  static double shakeAccelerationThreshold(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 12.0,
      MissionDifficulty.medium => 13.5,
      MissionDifficulty.hard => 15.0,
    };
  }

  static Duration shakeCooldown(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => const Duration(milliseconds: 320),
      MissionDifficulty.medium => const Duration(milliseconds: 280),
      MissionDifficulty.hard => const Duration(milliseconds: 250),
    };
  }

  // --- Word Scramble Mission ---
  static int wordScrambleWordCount(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 2,
      MissionDifficulty.medium => 3,
      MissionDifficulty.hard => 4,
    };
  }

  static String wordScrambleLengthLabel(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => '3–4 letters',
      MissionDifficulty.medium => '5–6 letters',
      MissionDifficulty.hard => '7–9 letters',
    };
  }

  // --- Color Sequence Mission ---
  static int colorSequenceLength(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 3,
      MissionDifficulty.medium => 5,
      MissionDifficulty.hard => 7,
    };
  }

  static Duration colorSequenceFlashDuration(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => const Duration(milliseconds: 500),
      MissionDifficulty.medium => const Duration(milliseconds: 420),
      MissionDifficulty.hard => const Duration(milliseconds: 350),
    };
  }

  // --- Typing Challenge Mission ---
  static int typingSentenceCount(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => 1,
      MissionDifficulty.medium => 2,
      MissionDifficulty.hard => 2,
    };
  }

  static String typingWordCountLabel(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => '3–5 words',
      MissionDifficulty.medium => '6–9 words',
      MissionDifficulty.hard => '10–15 words',
    };
  }
}
