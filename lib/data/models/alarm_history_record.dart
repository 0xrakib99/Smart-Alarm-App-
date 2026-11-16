enum AlarmHistoryStatus {
  completed,
  snoozed,
  missed,
  cancelled;

  String get displayName => switch (this) {
    AlarmHistoryStatus.completed => 'Completed',
    AlarmHistoryStatus.snoozed => 'Snoozed',
    AlarmHistoryStatus.missed => 'Missed',
    AlarmHistoryStatus.cancelled => 'Cancelled',
  };
}

class AlarmHistoryRecord {
  const AlarmHistoryRecord({
    required this.id,
    required this.alarmId,
    required this.alarmLabel,
    required this.scheduledTime,
    required this.actualTime,
    required this.status,
    this.selectedMissions = const <String>[],
    this.completedMissions = const <String>[],
    this.durationSeconds = 0,
    this.snoozeCount = 0,
    this.difficulty,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? actualTime;

  final String id;
  final String alarmId;
  final String alarmLabel;
  final DateTime scheduledTime;
  final DateTime actualTime;
  final AlarmHistoryStatus status;
  final List<String> selectedMissions;
  final List<String> completedMissions;
  final int durationSeconds;
  final int snoozeCount;
  final String? difficulty;
  final DateTime createdAt;

  AlarmHistoryRecord copyWith({
    String? id,
    String? alarmId,
    String? alarmLabel,
    DateTime? scheduledTime,
    DateTime? actualTime,
    AlarmHistoryStatus? status,
    List<String>? selectedMissions,
    List<String>? completedMissions,
    int? durationSeconds,
    int? snoozeCount,
    String? difficulty,
    DateTime? createdAt,
  }) {
    return AlarmHistoryRecord(
      id: id ?? this.id,
      alarmId: alarmId ?? this.alarmId,
      alarmLabel: alarmLabel ?? this.alarmLabel,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      status: status ?? this.status,
      selectedMissions: selectedMissions ?? this.selectedMissions,
      completedMissions: completedMissions ?? this.completedMissions,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'alarmId': alarmId,
      'alarmLabel': alarmLabel,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'actualTime': actualTime.millisecondsSinceEpoch,
      'status': status.name,
      'selectedMissions': selectedMissions,
      'completedMissions': completedMissions,
      'durationSeconds': durationSeconds,
      'snoozeCount': snoozeCount,
      'difficulty': difficulty,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AlarmHistoryRecord.fromMap(Map<dynamic, dynamic> map) {
    final statusName = map['status'] as String?;
    final resolvedStatus = AlarmHistoryStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => AlarmHistoryStatus.completed,
    );

    final scheduledMillis = map['scheduledTime'] as num?;
    final actualMillis = map['actualTime'] as num?;
    final createdMillis = map['createdAt'] as num?;

    final scheduled = scheduledMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(scheduledMillis.toInt())
        : DateTime.now();

    final actual = actualMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(actualMillis.toInt())
        : scheduled;

    final created = createdMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(createdMillis.toInt())
        : actual;

    final rawSelected = map['selectedMissions'];
    final selected = <String>[];
    if (rawSelected is List) {
      for (final item in rawSelected) {
        if (item is String) selected.add(item);
      }
    }

    final rawCompleted = map['completedMissions'];
    final completed = <String>[];
    if (rawCompleted is List) {
      for (final item in rawCompleted) {
        if (item is String) completed.add(item);
      }
    }

    return AlarmHistoryRecord(
      id: map['id']?.toString() ?? '',
      alarmId: map['alarmId']?.toString() ?? '',
      alarmLabel: map['alarmLabel']?.toString() ?? 'Alarm',
      scheduledTime: scheduled,
      actualTime: actual,
      status: resolvedStatus,
      selectedMissions: List<String>.unmodifiable(selected),
      completedMissions: List<String>.unmodifiable(completed),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      snoozeCount: (map['snoozeCount'] as num?)?.toInt() ?? 0,
      difficulty: map['difficulty'] as String?,
      createdAt: created,
    );
  }
}
