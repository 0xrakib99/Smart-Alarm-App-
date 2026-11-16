import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/core/services/alarm_state_service.dart';
import 'package:smart_alarm/data/models/mission_config.dart';
import 'package:smart_alarm/features/missions/core/config/mission_difficulty_config.dart';
import 'package:smart_alarm/features/missions/core/enums/mission_status.dart';
import 'package:smart_alarm/features/missions/core/models/mission_result.dart';
import 'package:smart_alarm/features/missions/memory/models/memory_card_item.dart';

class MemoryMissionController extends GetxController {
  MemoryMissionController({MissionDifficulty? difficulty})
    : difficulty = difficulty ?? MissionDifficulty.easy;

  late MissionDifficulty difficulty;

  final Rx<MissionStatus> status = MissionStatus.ready.obs;
  final RxList<MemoryCardItem> cards = <MemoryCardItem>[].obs;
  late final int totalPairs;
  late final int gridColumns;
  late final Duration peekDelay;

  final RxInt matchedPairs = 0.obs;
  final RxInt moves = 0.obs;
  final RxBool isComparing = false.obs;
  final Rxn<MissionResult> result = Rxn<MissionResult>();

  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  Timer? _flipTimer;
  late DateTime _startedAt;

  static const List<IconData> _iconPool = <IconData>[
    Icons.alarm_rounded,
    Icons.wb_sunny_rounded,
    Icons.star_rounded,
    Icons.coffee_rounded,
    Icons.bolt_rounded,
    Icons.fitness_center_rounded,
    Icons.lightbulb_rounded,
    Icons.favorite_rounded,
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final resolvedDifficulty = args is MissionConfig
        ? args.difficulty
        : (args is MissionDifficulty ? args : difficulty);
    difficulty = resolvedDifficulty;
    totalPairs = MissionDifficultyConfig.memoryPairCount(resolvedDifficulty);
    gridColumns = MissionDifficultyConfig.memoryGridColumns(resolvedDifficulty);
    peekDelay = MissionDifficultyConfig.memoryPeekDelay(resolvedDifficulty);
    startSession();
  }

  @override
  void onClose() {
    _flipTimer?.cancel();
    super.onClose();
  }

  void startSession() {
    _flipTimer?.cancel();
    _firstSelectedIndex = null;
    _secondSelectedIndex = null;
    isComparing.value = false;
    matchedPairs.value = 0;
    moves.value = 0;
    result.value = null;
    _startedAt = DateTime.now();

    final pool = List<IconData>.from(_iconPool)..shuffle();
    final selectedIcons = pool.take(totalPairs).toList(growable: false);

    final List<MemoryCardItem> generatedCards = <MemoryCardItem>[];
    int idCounter = 0;

    for (int i = 0; i < selectedIcons.length; i++) {
      final icon = selectedIcons[i];
      // Card 1 of pair
      generatedCards.add(
        MemoryCardItem(id: idCounter++, pairId: i, icon: icon),
      );
      // Card 2 of pair
      generatedCards.add(
        MemoryCardItem(id: idCounter++, pairId: i, icon: icon),
      );
    }

    generatedCards.shuffle();
    cards.assignAll(generatedCards);
    status.value = MissionStatus.inProgress;
  }

  void onCardTapped(int index) {
    if (isComparing.value || status.value != MissionStatus.inProgress) {
      return;
    }

    if (index < 0 || index >= cards.length) {
      return;
    }

    if (Get.isRegistered<AlarmStateService>()) {
      Get.find<AlarmStateService>().reportMissionInteraction();
    }

    final card = cards[index];
    if (card.isFaceUp.value || card.isMatched.value) {
      return;
    }

    card.flipUp();

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _secondSelectedIndex = index;
      moves.value++;
      isComparing.value = true;

      final firstCard = cards[_firstSelectedIndex!];
      final secondCard = cards[_secondSelectedIndex!];

      if (firstCard.pairId == secondCard.pairId) {
        // Matched!
        firstCard.markMatched();
        secondCard.markMatched();
        matchedPairs.value++;

        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
        isComparing.value = false;

        if (matchedPairs.value >= totalPairs) {
          _completeMission();
        }
      } else {
        // Not matched, hide after delay
        _flipTimer = Timer(peekDelay, () {
          firstCard.flipDown();
          secondCard.flipDown();
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
          isComparing.value = false;
        });
      }
    }
  }

  void _completeMission() {
    _flipTimer?.cancel();
    status.value = MissionStatus.completed;
    final now = DateTime.now();
    result.value = MissionResult(
      type: MissionType.memory,
      difficulty: difficulty,
      isSuccess: true,
      startedAt: _startedAt,
      completedAt: now,
      moves: moves.value,
      attempts: moves.value,
      metrics: <String, dynamic>{
        'Pairs matched': '$totalPairs / $totalPairs',
        'Total moves': '${moves.value}',
      },
    );
  }
}
