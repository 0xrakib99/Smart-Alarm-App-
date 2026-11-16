import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemoryCardItem {
  MemoryCardItem({
    required this.id,
    required this.pairId,
    required this.icon,
    bool isFaceUp = false,
    bool isMatched = false,
  }) : isFaceUp = isFaceUp.obs,
       isMatched = isMatched.obs;

  final int id;
  final int pairId;
  final IconData icon;
  final RxBool isFaceUp;
  final RxBool isMatched;

  void flipUp() {
    isFaceUp.value = true;
  }

  void flipDown() {
    isFaceUp.value = false;
  }

  void markMatched() {
    isMatched.value = true;
    isFaceUp.value = true;
  }
}
