import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/typing/data/typing_sentences.dart';

class TypingMissionController extends GetxController {
  TypingMissionController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxInt currentIndex = 0.obs;
  late final int totalSentences;

  final RxString targetSentence = ''.obs;
  final RxString typedText = ''.obs;
  final RxInt accuracy = 100.obs;
  final RxnString feedbackMessage = RxnString();
  final RxBool isCorrect = false.obs;

  final RxInt moves = 0.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  late final TextEditingController textController;
  late final FocusNode focusNode;

  late DateTime _startedAt;
  final List<String> _sessionSentences = <String>[];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    totalSentences = MissionDifficultyConfig.typingSentenceCount(
      resolvedDifficulty,
    );

    textController = TextEditingController();
    focusNode = FocusNode();

    startSession();
  }

  void startSession() {
    currentIndex.value = 0;
    moves.value = 0;
    result.value = null;
    _startedAt = DateTime.now();

    final allSentences = List<String>.from(
      TypingSentences.getSentencesForDifficulty(difficulty),
    );
    allSentences.shuffle(Random());

    _sessionSentences.clear();
    final count = min(totalSentences, allSentences.length);
    for (int i = 0; i < count; i++) {
      _sessionSentences.add(allSentences[i]);
    }

    _loadSentence(0);
    status.value = MissionStatus.inProgress;
  }

  void _loadSentence(int index) {
    if (index >= _sessionSentences.length) return;
    targetSentence.value = _sessionSentences[index];
    typedText.value = '';
    textController.text = '';
    accuracy.value = 100;
    feedbackMessage.value = null;
    isCorrect.value = false;
  }

  void onTextChanged(String text) {
    if (status.value != MissionStatus.inProgress) return;
    typedText.value = text;
    moves.value++;
    _reportInteraction();

    final target = targetSentence.value;
    int correctChars = 0;
    final compareLength = min(text.length, target.length);

    for (int i = 0; i < compareLength; i++) {
      if (text[i] == target[i]) {
        correctChars++;
      }
    }

    if (text.isNotEmpty) {
      accuracy.value = ((correctChars / text.length) * 100).round();
    } else {
      accuracy.value = 100;
    }

    // Check for exact match
    if (text.trim() == target.trim()) {
      isCorrect.value = true;
      feedbackMessage.value = 'Perfect typing!';
      Future.delayed(const Duration(milliseconds: 500), () {
        submitSentence();
      });
    } else {
      feedbackMessage.value = null;
    }
  }

  void clearText() {
    if (status.value != MissionStatus.inProgress) return;
    textController.clear();
    typedText.value = '';
    accuracy.value = 100;
    feedbackMessage.value = null;
    _reportInteraction();
  }

  void submitSentence() {
    if (status.value != MissionStatus.inProgress) return;
    _reportInteraction();

    final typed = textController.text.trim();
    final target = targetSentence.value.trim();

    if (typed == target) {
      isCorrect.value = true;
      feedbackMessage.value = 'Sentence matched!';

      Future.delayed(const Duration(milliseconds: 500), () {
        if (currentIndex.value + 1 < _sessionSentences.length) {
          currentIndex.value++;
          _loadSentence(currentIndex.value);
        } else {
          _completeMission();
        }
      });
    } else {
      feedbackMessage.value = 'Text does not match target. Check errors!';
    }
  }

  void _completeMission() {
    status.value = MissionStatus.completed;
    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.typing,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: moves.value,
      attempts: _sessionSentences.length,
      metrics: <String, dynamic>{
        'Sentences': '${_sessionSentences.length}/$totalSentences',
        'Accuracy': '${accuracy.value}%',
      },
    );
  }

  void _reportInteraction() {
    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }
  }

  @override
  void onClose() {
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
