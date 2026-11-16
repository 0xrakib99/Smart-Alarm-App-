import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/color_sequence/controllers/color_sequence_controller.dart';
import 'package:smart_alarm/features/missions/color_sequence/models/sequence_color.dart';
import 'package:smart_alarm/features/missions/controllers/mission_selection_controller.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/puzzle/controllers/puzzle_mission_controller.dart';
import 'package:smart_alarm/features/missions/typing/controllers/typing_mission_controller.dart';
import 'package:smart_alarm/features/missions/typing/data/typing_sentences.dart';
import 'package:smart_alarm/features/missions/word_scramble/controllers/word_scramble_controller.dart';
import 'package:smart_alarm/features/missions/word_scramble/data/word_scramble_words.dart';
import 'package:smart_alarm/features/missions/word_scramble/models/word_scramble_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Word Scramble Mission', () {
    test('Curated words have valid lengths for each difficulty', () {
      for (final word in WordScrambleWords.getWordsForDifficulty(
        MissionDifficulty.easy,
      )) {
        expect(word.length, inInclusiveRange(3, 4));
      }
      for (final word in WordScrambleWords.getWordsForDifficulty(
        MissionDifficulty.medium,
      )) {
        expect(word.length, inInclusiveRange(5, 6));
      }
      for (final word in WordScrambleWords.getWordsForDifficulty(
        MissionDifficulty.hard,
      )) {
        expect(word.length, inInclusiveRange(7, 9));
      }
    });

    test('Scramble generator produces different text from original', () {
      for (int i = 0; i < 20; i++) {
        final item = WordScrambleItem.fromWord('MORNING');
        expect(item.originalWord, 'MORNING');
        expect(item.scrambledWord, isNot('MORNING'));
        expect(item.scrambledWord.length, 7);
      }
    });

    test('WordScrambleController letter selection, clear, undo and hint', () {
      final controller = WordScrambleController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      expect(controller.totalWords, 2);
      expect(controller.currentIndex.value, 0);
      expect(controller.selectedLetters, isEmpty);
      expect(
        controller.availableLetters.length,
        controller.currentWord.value!.originalWord.length,
      );

      // Select first available letter
      final firstLetter = controller.availableLetters.first;
      controller.selectBankLetter(0);

      expect(controller.selectedLetters.length, 1);
      expect(controller.selectedLetters.first, firstLetter);

      // Undo (backspace)
      controller.backspace();
      expect(controller.selectedLetters, isEmpty);
      expect(controller.availableLetters.contains(firstLetter), isTrue);

      // Select again and Clear
      controller.selectBankLetter(0);
      expect(controller.selectedLetters.length, 1);
      controller.clearAnswer();
      expect(controller.selectedLetters, isEmpty);

      // Hint: reveals the correct first letter
      final originalWord = controller.currentWord.value!.originalWord;
      controller.useHint();
      expect(controller.selectedLetters.length, 1);
      expect(controller.selectedLetters.first, originalWord[0]);
      expect(controller.hintsUsed.value, 1);

      // Second hint should not apply (only 1 hint per word)
      controller.useHint();
      expect(controller.selectedLetters.length, 1);

      controller.onClose();
    });

    test('WordScrambleController handles wrong submission and success', () {
      final controller = WordScrambleController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      // Submit incomplete word
      controller.clearAnswer();
      controller.submitAnswer();
      expect(controller.isCorrect.value, isFalse);

      // Solve first word
      final target = controller.currentWord.value!.originalWord;
      controller.clearAnswer();
      for (int i = 0; i < target.length; i++) {
        final char = target[i];
        final bankIdx = controller.availableLetters.indexOf(char);
        if (bankIdx != -1) {
          controller.selectBankLetter(bankIdx);
        }
      }
      controller.submitAnswer();
      expect(controller.isCorrect.value, isTrue);

      controller.onClose();
    });
  });

  group('Color Sequence Mission', () {
    test('Sequence configuration matches difficulty specifications', () {
      expect(
        MissionDifficultyConfig.colorSequenceLength(MissionDifficulty.easy),
        3,
      );
      expect(
        MissionDifficultyConfig.colorSequenceLength(MissionDifficulty.medium),
        5,
      );
      expect(
        MissionDifficultyConfig.colorSequenceLength(MissionDifficulty.hard),
        7,
      );
    });

    test(
      'ColorSequenceController sequence generation and pad tap matching',
      () {
        final controller = ColorSequenceController(
          difficulty: MissionDifficulty.easy,
        );
        controller.onInit();

        // Sequence should have 3 items for Easy
        expect(controller.targetSequence.length, 3);
        expect(controller.targetLength, 3);
        expect(controller.userInputs, isEmpty);

        // While demonstrating, taps should be blocked
        controller.isDemonstrating.value = true;
        final firstColor = controller.targetSequence.first;
        controller.tapColor(firstColor);
        expect(controller.userInputs, isEmpty); // Still empty because locked

        // Unlock and tap wrong color first -> triggers error shake
        controller.isDemonstrating.value = false;
        final wrongColor = SequenceColor.values.firstWhere(
          (c) => c != controller.targetSequence[0],
        );
        controller.tapColor(wrongColor);
        expect(controller.hasError.value, isTrue);

        // Tap correct color -> completes round 1 and prepares round 2
        controller.isDemonstrating.value = false;
        controller.hasError.value = false;
        controller.tapColor(firstColor);
        expect(controller.currentRound.value, 2);
        expect(controller.isDemonstrating.value, isTrue);

        controller.onClose();
      },
    );
  });

  group('Typing Challenge Mission', () {
    test('Curated sentences exist for all difficulty levels', () {
      expect(
        TypingSentences.getSentencesForDifficulty(MissionDifficulty.easy),
        isNotEmpty,
      );
      expect(
        TypingSentences.getSentencesForDifficulty(MissionDifficulty.medium),
        isNotEmpty,
      );
      expect(
        TypingSentences.getSentencesForDifficulty(MissionDifficulty.hard),
        isNotEmpty,
      );
    });

    test('TypingMissionController live matching and accuracy calculation', () {
      final controller = TypingMissionController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      expect(controller.totalSentences, 1);
      final target = controller.targetSentence.value;
      expect(target, isNotEmpty);

      // Type partial correct text
      final prefix = target.substring(0, target.length ~/ 2);
      controller.textController.text = prefix;
      controller.onTextChanged(prefix);

      expect(controller.accuracy.value, 100);

      // Type an incorrect character
      final wrongText = '$prefix@#\$';
      controller.textController.text = wrongText;
      controller.onTextChanged(wrongText);

      expect(controller.accuracy.value, lessThan(100));

      // Clear text
      controller.clearText();
      expect(controller.textController.text, '');
      expect(controller.accuracy.value, 100);

      controller.onClose();
    });
  });

  group('Number Puzzle Mission', () {
    test('PuzzleMissionController moves, progress and restart', () {
      final controller = PuzzleMissionController(
        difficulty: MissionDifficulty.easy,
      );
      controller.onInit();

      expect(controller.gridSize, 3);
      expect(controller.tiles.length, 9);
      expect(controller.totalTiles, 8);
      expect(controller.moves.value, 0);

      // Progress percentage is calculated
      expect(controller.progressPercentage, inInclusiveRange(0.0, 1.0));

      // Restart resets moves to 0
      controller.moves.value = 15;
      controller.restart();
      expect(controller.moves.value, 0);
      expect(controller.tiles.length, 9);

      controller.onClose();
    });
  });

  group('Mission Selection Controller (Multi-Mission)', () {
    test('Multi-mission selection toggles and independent difficulties', () {
      final controller = MissionSelectionController();

      expect(controller.hasSelection, isFalse);
      expect(controller.selectedCount, 0);

      // Select Word Scramble
      controller.toggleMission(MissionType.wordScramble);
      expect(controller.isSelected(MissionType.wordScramble), isTrue);
      expect(controller.selectedCount, 1);
      expect(
        controller.getDifficulty(MissionType.wordScramble),
        MissionDifficulty.easy,
      );

      // Set difficulty for Word Scramble to Hard
      controller.setMissionDifficulty(
        MissionType.wordScramble,
        MissionDifficulty.hard,
      );
      expect(
        controller.getDifficulty(MissionType.wordScramble),
        MissionDifficulty.hard,
      );

      // Select Color Sequence with Medium difficulty
      controller.toggleMission(MissionType.colorSequence);
      controller.setMissionDifficulty(
        MissionType.colorSequence,
        MissionDifficulty.medium,
      );

      expect(controller.selectedCount, 2);
      expect(controller.isSelected(MissionType.wordScramble), isTrue);
      expect(controller.isSelected(MissionType.colorSequence), isTrue);

      final selections = controller.selections;
      expect(selections.length, 2);
      expect(selections[0].type, MissionType.wordScramble);
      expect(selections[0].difficulty, MissionDifficulty.hard);
      expect(selections[1].type, MissionType.colorSequence);
      expect(selections[1].difficulty, MissionDifficulty.medium);

      // Toggle off Word Scramble
      controller.toggleMission(MissionType.wordScramble);
      expect(controller.isSelected(MissionType.wordScramble), isFalse);
      expect(controller.selectedCount, 1);

      controller.onClose();
    });

    test('Initial selection populated from List<MissionConfig>', () {
      final initial = <MissionConfig>[
        const MissionConfig(
          type: MissionType.puzzle,
          difficulty: MissionDifficulty.medium,
        ),
        const MissionConfig(
          type: MissionType.typing,
          difficulty: MissionDifficulty.hard,
        ),
      ];

      final controller = MissionSelectionController(initialSelection: initial);
      expect(controller.selectedCount, 2);
      expect(controller.isSelected(MissionType.puzzle), isTrue);
      expect(
        controller.getDifficulty(MissionType.puzzle),
        MissionDifficulty.medium,
      );
      expect(controller.isSelected(MissionType.typing), isTrue);
      expect(
        controller.getDifficulty(MissionType.typing),
        MissionDifficulty.hard,
      );

      controller.onClose();
    });
  });
}
