import 'package:smart_alarm/data/models/mission_config.dart';

class MissionResult {
  const MissionResult({
    required this.type,
    required this.difficulty,
    required this.isSuccess,
    required this.startedAt,
    required this.completedAt,
    this.moves = 0,
    this.attempts = 0,
    this.metrics = const <String, dynamic>{},
  });

  final MissionType type;
  final MissionDifficulty difficulty;
  final bool isSuccess;
  final DateTime startedAt;
  final DateTime completedAt;
  final int moves;
  final int attempts;
  final Map<String, dynamic> metrics;

  Duration get duration => completedAt.difference(startedAt);

  String get formattedDuration {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = duration.inMinutes;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds.toString().padLeft(2, '0')}s';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'difficulty': difficulty.name,
      'isSuccess': isSuccess,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'moves': moves,
      'attempts': attempts,
      'metrics': metrics,
    };
  }

  @override
  String toString() {
    return 'MissionResult(type: ${type.name}, difficulty: ${difficulty.name}, isSuccess: $isSuccess, duration: $formattedDuration, moves: $moves, attempts: $attempts)';
  }
}
