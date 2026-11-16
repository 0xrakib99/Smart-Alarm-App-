import 'dart:math';
import 'package:smart_alarm/data/models/mission_config.dart';

enum MathOperation { addition, subtraction, multiplication, division, mixed }

class MathProblem {
  const MathProblem({
    required this.expression,
    required this.correctAnswer,
    required this.options,
  });

  final String expression;
  final int correctAnswer;
  final List<int> options;

  static final Random _random = Random();

  static MathProblem generate(
    MissionDifficulty difficulty, {
    Set<String>? seenExpressions,
  }) {
    for (int attempt = 0; attempt < 50; attempt++) {
      final problem = _createCandidate(difficulty);
      if (seenExpressions == null ||
          !seenExpressions.contains(problem.expression)) {
        return problem;
      }
    }
    // Fallback if all attempts had collision
    return _createCandidate(difficulty);
  }

  static MathProblem _createCandidate(MissionDifficulty difficulty) {
    return switch (difficulty) {
      MissionDifficulty.easy => _generateEasy(),
      MissionDifficulty.medium => _generateMedium(),
      MissionDifficulty.hard => _generateHard(),
    };
  }

  static MathProblem _generateEasy() {
    final op = _random.nextInt(4); // 0: +, 1: -, 2: *, 3: /
    String expression;
    int answer;

    switch (op) {
      case 0:
        final a = _random.nextInt(15) + 3;
        final b = _random.nextInt(15) + 2;
        expression = '$a + $b';
        answer = a + b;
        break;
      case 1:
        final b = _random.nextInt(12) + 2;
        final a = b + _random.nextInt(15) + 1; // ensure a > b
        expression = '$a - $b';
        answer = a - b;
        break;
      case 2:
        final a = _random.nextInt(8) + 2;
        final b = _random.nextInt(8) + 2;
        expression = '$a × $b';
        answer = a * b;
        break;
      case 3:
      default:
        final b = _random.nextInt(7) + 2;
        final quotient = _random.nextInt(8) + 2;
        final a = b * quotient;
        expression = '$a ÷ $b';
        answer = quotient;
        break;
    }

    final options = _generateOptions(answer);
    return MathProblem(
      expression: expression,
      correctAnswer: answer,
      options: options,
    );
  }

  static MathProblem _generateMedium() {
    final op = _random.nextInt(5); // 0: +, 1: -, 2: *, 3: /, 4: mixed
    String expression;
    int answer;

    switch (op) {
      case 0:
        final a = _random.nextInt(60) + 15;
        final b = _random.nextInt(60) + 15;
        expression = '$a + $b';
        answer = a + b;
        break;
      case 1:
        final b = _random.nextInt(50) + 10;
        final a = b + _random.nextInt(60) + 5;
        expression = '$a - $b';
        answer = a - b;
        break;
      case 2:
        final a = _random.nextInt(13) + 4;
        final b = _random.nextInt(12) + 3;
        expression = '$a × $b';
        answer = a * b;
        break;
      case 3:
        final b = _random.nextInt(11) + 3;
        final quotient = _random.nextInt(12) + 3;
        final a = b * quotient;
        expression = '$a ÷ $b';
        answer = quotient;
        break;
      case 4:
      default:
        // Mixed: a + b - c or a * b + c
        if (_random.nextBool()) {
          final a = _random.nextInt(25) + 10;
          final b = _random.nextInt(25) + 10;
          final c = _random.nextInt(15) + 3;
          expression = '$a + $b - $c';
          answer = a + b - c;
        } else {
          final a = _random.nextInt(7) + 3;
          final b = _random.nextInt(7) + 2;
          final c = _random.nextInt(20) + 5;
          expression = '$a × $b + $c';
          answer = a * b + c;
        }
        break;
    }

    final options = _generateOptions(answer);
    return MathProblem(
      expression: expression,
      correctAnswer: answer,
      options: options,
    );
  }

  static MathProblem _generateHard() {
    final opType = _random.nextInt(4);
    String expression;
    int answer;

    switch (opType) {
      case 0:
        // a * b - c
        final a = _random.nextInt(12) + 6;
        final b = _random.nextInt(12) + 4;
        final c = _random.nextInt(30) + 5;
        expression = '$a × $b - $c';
        answer = (a * b) - c;
        break;
      case 1:
        // a + b * c
        final a = _random.nextInt(50) + 15;
        final b = _random.nextInt(11) + 3;
        final c = _random.nextInt(11) + 3;
        expression = '$a + $b × $c';
        answer = a + (b * c);
        break;
      case 2:
        // (a + b) * c
        final a = _random.nextInt(15) + 5;
        final b = _random.nextInt(15) + 5;
        final c = _random.nextInt(6) + 3;
        expression = '($a + $b) × $c';
        answer = (a + b) * c;
        break;
      case 3:
      default:
        // a * b + c * d
        final a = _random.nextInt(9) + 3;
        final b = _random.nextInt(9) + 2;
        final c = _random.nextInt(9) + 2;
        final d = _random.nextInt(8) + 2;
        expression = '$a × $b + $c × $d';
        answer = (a * b) + (c * d);
        break;
    }

    final options = _generateOptions(answer);
    return MathProblem(
      expression: expression,
      correctAnswer: answer,
      options: options,
    );
  }

  static List<int> _generateOptions(int correct) {
    final Set<int> options = <int>{correct};
    final List<int> offsets = <int>[
      1,
      -1,
      2,
      -2,
      3,
      -3,
      5,
      -5,
      10,
      -10,
      4,
      -4,
      6,
      -6,
      7,
      -7,
    ]..shuffle(_random);

    for (final offset in offsets) {
      if (options.length >= 4) {
        break;
      }
      final candidate = correct + offset;
      if (candidate != correct) {
        options.add(candidate);
      }
    }

    // Safety fallback if not enough options
    int extra = 1;
    while (options.length < 4) {
      options.add(correct + 10 + extra);
      extra++;
    }

    final list = options.toList()..shuffle(_random);
    return list;
  }
}
