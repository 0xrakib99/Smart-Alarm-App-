import 'dart:async';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/math/models/math_problem.dart';

class MathMissionController extends GetxController {
  MathMissionController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxInt currentIndex = 0.obs;
  late final int totalQuestions;
  final Rxn<MathProblem> currentProblem = Rxn<MathProblem>();
  final Rxn<int> selectedOption = Rxn<int>();
  final RxBool isEvaluating = false.obs;
  final Rxn<bool> lastAnswerCorrect = Rxn<bool>();
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  final Set<String> _seenQuestions = <String>{};
  late DateTime _startedAt;
  int _totalAttempts = 0;
  int _wrongAttempts = 0;
  Timer? _evalTimer;

  int get totalAttempts => _totalAttempts;
  int get wrongAttempts => _wrongAttempts;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    totalQuestions = MissionDifficultyConfig.mathQuestionCount(
      resolvedDifficulty,
    );
    startSession();
  }

  @override
  void onClose() {
    _evalTimer?.cancel();
    super.onClose();
  }

  void startSession() {
    _evalTimer?.cancel();
    _seenQuestions.clear();
    _totalAttempts = 0;
    _wrongAttempts = 0;
    currentIndex.value = 0;
    selectedOption.value = null;
    isEvaluating.value = false;
    lastAnswerCorrect.value = null;
    result.value = null;
    _startedAt = DateTime.now();
    status.value = MissionStatus.inProgress;
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    selectedOption.value = null;
    isEvaluating.value = false;
    lastAnswerCorrect.value = null;
    final problem = MathProblem.generate(
      difficulty,
      seenExpressions: _seenQuestions,
    );
    _seenQuestions.add(problem.expression);
    currentProblem.value = problem;
  }

  void selectAnswer(int option) {
    if (isEvaluating.value || status.value != MissionStatus.inProgress) {
      return;
    }

    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }

    final problem = currentProblem.value;
    if (problem == null) {
      return;
    }

    isEvaluating.value = true;
    selectedOption.value = option;
    _totalAttempts++;

    final isCorrect = option == problem.correctAnswer;
    lastAnswerCorrect.value = isCorrect;

    if (isCorrect) {
      _evalTimer = Timer(const Duration(milliseconds: 550), () {
        if (currentIndex.value + 1 >= totalQuestions) {
          _completeMission();
        } else {
          currentIndex.value++;
          _loadNextQuestion();
        }
      });
    } else {
      _wrongAttempts++;
      _evalTimer = Timer(const Duration(milliseconds: 650), () {
        selectedOption.value = null;
        lastAnswerCorrect.value = null;
        isEvaluating.value = false;
      });
    }
  }

  void _completeMission() {
    final now = DateTime.now();
    status.value = MissionStatus.completed;
    result.value = MissionResult(
      type: MissionType.math,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: totalQuestions,
      attempts: _totalAttempts,
      metrics: <String, dynamic>{
        'Solved': '$totalQuestions / $totalQuestions',
        'Wrong attempts': '$_wrongAttempts',
      },
    );
  }
}
