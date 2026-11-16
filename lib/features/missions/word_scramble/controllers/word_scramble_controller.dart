import 'dart:math';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/word_scramble/data/word_scramble_words.dart';
import 'package:smart_alarm/features/missions/word_scramble/models/word_scramble_item.dart';

class WordScrambleController extends GetxController {
  WordScrambleController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxInt currentIndex = 0.obs;
  late final int totalWords;

  final Rxn<WordScrambleItem> currentWord = Rxn<WordScrambleItem>();
  final RxList<String> availableLetters = <String>[].obs;
  final RxList<String> selectedLetters = <String>[].obs;
  final RxInt hintsUsed = 0.obs;
  final RxnString feedbackMessage = RxnString();
  final RxBool isCorrect = false.obs;

  final RxInt moves = 0.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  late DateTime _startedAt;
  final List<WordScrambleItem> _sessionWords = <WordScrambleItem>[];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    totalWords = MissionDifficultyConfig.wordScrambleWordCount(
      resolvedDifficulty,
    );
    startSession();
  }

  void startSession() {
    currentIndex.value = 0;
    moves.value = 0;
    result.value = null;
    _startedAt = DateTime.now();

    final allWords = List<String>.from(
      WordScrambleWords.getWordsForDifficulty(difficulty),
    );
    allWords.shuffle(Random());

    _sessionWords.clear();
    final count = min(totalWords, allWords.length);
    for (int i = 0; i < count; i++) {
      _sessionWords.add(WordScrambleItem.fromWord(allWords[i]));
    }

    _loadWord(0);
    status.value = MissionStatus.inProgress;
  }

  void _loadWord(int index) {
    if (index >= _sessionWords.length) return;
    final item = _sessionWords[index];
    currentWord.value = item;
    availableLetters.assignAll(item.scrambledWord.split(''));
    selectedLetters.clear();
    hintsUsed.value = 0;
    feedbackMessage.value = null;
    isCorrect.value = false;
  }

  void selectBankLetter(int index) {
    if (status.value != MissionStatus.inProgress) return;
    if (index < 0 || index >= availableLetters.length) return;

    _reportInteraction();
    final letter = availableLetters.removeAt(index);
    selectedLetters.add(letter);
    moves.value++;
    feedbackMessage.value = null;
  }

  void unselectLetter(int index) {
    if (status.value != MissionStatus.inProgress) return;
    if (index < 0 || index >= selectedLetters.length) return;

    _reportInteraction();
    final letter = selectedLetters.removeAt(index);
    availableLetters.add(letter);
    moves.value++;
    feedbackMessage.value = null;
  }

  void clearAnswer() {
    if (status.value != MissionStatus.inProgress) return;
    if (selectedLetters.isEmpty) return;

    _reportInteraction();
    availableLetters.addAll(selectedLetters);
    selectedLetters.clear();
    feedbackMessage.value = null;
  }

  void backspace() {
    if (status.value != MissionStatus.inProgress) return;
    if (selectedLetters.isEmpty) return;

    _reportInteraction();
    final last = selectedLetters.removeLast();
    availableLetters.add(last);
    feedbackMessage.value = null;
  }

  void useHint() {
    if (status.value != MissionStatus.inProgress) return;
    final word = currentWord.value;
    if (word == null) return;
    if (hintsUsed.value >= 1) {
      feedbackMessage.value = 'Only 1 hint allowed per word';
      return;
    }

    _reportInteraction();
    final targetLetters = word.originalWord.split('');
    final targetIndex = selectedLetters.length;

    if (targetIndex >= targetLetters.length) return;
    final expectedLetter = targetLetters[targetIndex];

    final bankIndex = availableLetters.indexOf(expectedLetter);
    if (bankIndex != -1) {
      final letter = availableLetters.removeAt(bankIndex);
      selectedLetters.add(letter);
      hintsUsed.value++;
      feedbackMessage.value = 'Hint applied: $letter';
    } else {
      // Letter might already be in an incorrect spot in selectedLetters; clear incorrect suffix
      clearAnswer();
      final freshIndex = availableLetters.indexOf(expectedLetter);
      if (freshIndex != -1) {
        final letter = availableLetters.removeAt(freshIndex);
        selectedLetters.add(letter);
        hintsUsed.value++;
        feedbackMessage.value = 'Hint applied: $letter';
      }
    }
  }

  void submitAnswer() {
    if (status.value != MissionStatus.inProgress) return;
    final word = currentWord.value;
    if (word == null) return;

    _reportInteraction();
    final entered = selectedLetters.join('').trim().toUpperCase();

    if (entered == word.originalWord) {
      isCorrect.value = true;
      feedbackMessage.value = 'Correct!';

      Future.delayed(const Duration(milliseconds: 600), () {
        if (currentIndex.value + 1 < _sessionWords.length) {
          currentIndex.value++;
          _loadWord(currentIndex.value);
        } else {
          _completeMission();
        }
      });
    } else {
      feedbackMessage.value = 'Not quite right. Try again!';
    }
  }

  void _completeMission() {
    status.value = MissionStatus.completed;
    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.wordScramble,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: moves.value,
      attempts: _sessionWords.length,
      metrics: <String, dynamic>{
        'Words completed': '${_sessionWords.length}/$totalWords',
        'Difficulty': difficulty.label,
      },
    );
  }

  void _reportInteraction() {
    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }
  }
}
