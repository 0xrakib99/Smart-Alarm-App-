import 'package:smart_alarm/data/models/mission_config.dart';

abstract final class TypingSentences {
  static const List<String> easySentences = <String>[
    'Wake up and shine.',
    'Today is a new day.',
    'Start with a smile.',
    'Ready for the morning.',
    'Time to get active.',
    'Good morning to you.',
    'Make today count.',
    'Breathe in fresh air.',
    'A bright day awaits.',
    'Focus on the present.',
    'Keep your mind calm.',
    'Rise with great energy.',
    'Embrace this new dawn.',
    'Chase your dreams today.',
    'Enjoy this fresh morning.',
  ];

  static const List<String> mediumSentences = <String>[
    'Early morning sunlight brings fresh energy to your day.',
    'Discipline and consistency lead to great personal success.',
    'A focused mind achieves wonderful things every single day.',
    'Take a deep breath and start your routine now.',
    'Clear your thoughts and embrace a peaceful morning.',
    'Positive habits build a happy and fulfilling life.',
    'Rise early to conquer your goals with confidence.',
    'Every morning brings a new reason to celebrate.',
    'Healthy morning choices shape a productive day ahead.',
    'Step out of bed with courage and enthusiasm.',
  ];

  static const List<String> hardSentences = <String>[
    'The secret of getting ahead is getting started with courage, focus, and quiet determination.',
    'Every morning offers a brand new opportunity to learn, grow, and become your best self.',
    'Success is the sum of small daily efforts repeated with patience, passion, and relentless persistence.',
    'Great accomplishments require time, patience, positive thinking, and consistent hard work every single morning.',
    'Believe in yourself and your ability to overcome any obstacle that stands before you today.',
    'The morning breeze carries fresh inspiration for anyone ready to pursue their greatest dreams.',
    'Commit yourself to excellence today and build the future you have always envisioned.',
    'Cultivate a resilient mindset that transforms daily morning challenges into remarkable opportunities.',
  ];

  static List<String> getSentencesForDifficulty(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => easySentences,
      MissionDifficulty.medium => mediumSentences,
      MissionDifficulty.hard => hardSentences,
    };
  }
}
