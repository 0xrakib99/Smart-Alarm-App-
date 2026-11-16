import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/math/models/math_problem.dart';

void main() {
  group('MathProblem Generator', () {
    test('generates valid Easy problems', () {
      for (int i = 0; i < 20; i++) {
        final problem = MathProblem.generate(MissionDifficulty.easy);
        expect(problem.expression.isNotEmpty, isTrue);
        expect(problem.options.length, 4);
        expect(problem.options.toSet().length, 4); // all unique
        expect(problem.options.contains(problem.correctAnswer), isTrue);
      }
    });

    test('generates valid Medium problems', () {
      for (int i = 0; i < 20; i++) {
        final problem = MathProblem.generate(MissionDifficulty.medium);
        expect(problem.expression.isNotEmpty, isTrue);
        expect(problem.options.length, 4);
        expect(problem.options.toSet().length, 4);
        expect(problem.options.contains(problem.correctAnswer), isTrue);
      }
    });

    test('generates valid Hard problems', () {
      for (int i = 0; i < 20; i++) {
        final problem = MathProblem.generate(MissionDifficulty.hard);
        expect(problem.expression.isNotEmpty, isTrue);
        expect(problem.options.length, 4);
        expect(problem.options.toSet().length, 4);
        expect(problem.options.contains(problem.correctAnswer), isTrue);
      }
    });

    test('avoids seen questions where possible', () {
      final seen = <String>{};
      for (int i = 0; i < 5; i++) {
        final problem = MathProblem.generate(
          MissionDifficulty.easy,
          seenExpressions: seen,
        );
        expect(seen.contains(problem.expression), isFalse);
        seen.add(problem.expression);
      }
    });
  });
}
