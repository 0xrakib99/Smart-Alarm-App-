import 'package:flutter/material.dart';

enum SequenceColor {
  red,
  blue,
  green,
  amber;

  String get displayName => switch (this) {
    SequenceColor.red => 'Red',
    SequenceColor.blue => 'Blue',
    SequenceColor.green => 'Green',
    SequenceColor.amber => 'Amber',
  };

  Color get baseColor => switch (this) {
    SequenceColor.red => const Color(0xFFD32F2F),
    SequenceColor.blue => const Color(0xFF1976D2),
    SequenceColor.green => const Color(0xFF388E3C),
    SequenceColor.amber => const Color(0xFFF57C00),
  };

  Color get activeColor => switch (this) {
    SequenceColor.red => const Color(0xFFFF5252),
    SequenceColor.blue => const Color(0xFF448AFF),
    SequenceColor.green => const Color(0xFF69F0AE),
    SequenceColor.amber => const Color(0xFFFFD740),
  };
}
