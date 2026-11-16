import 'dart:math';

class WordScrambleItem {
  const WordScrambleItem({
    required this.originalWord,
    required this.scrambledWord,
  });

  final String originalWord;
  final String scrambledWord;

  static WordScrambleItem fromWord(String word, [Random? random]) {
    final rng = random ?? Random();
    final upper = word.trim().toUpperCase();
    final letters = upper.split('');

    if (letters.length <= 1) {
      return WordScrambleItem(originalWord: upper, scrambledWord: upper);
    }

    String scrambled = upper;
    int attempts = 0;
    while (scrambled == upper && attempts < 20) {
      letters.shuffle(rng);
      scrambled = letters.join('');
      attempts++;
    }

    // Fallback if random shuffle happens to equal original: reverse or shift
    if (scrambled == upper) {
      scrambled = letters.reversed.join('');
      if (scrambled == upper && letters.length > 2) {
        final first = letters.removeAt(0);
        letters.add(first);
        scrambled = letters.join('');
      }
    }

    return WordScrambleItem(originalWord: upper, scrambledWord: scrambled);
  }
}
