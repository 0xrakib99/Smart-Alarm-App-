import 'package:smart_alarm/data/models/alarm_model.dart';

abstract final class AppDateUtils {
  static const List<String> _weekdayNames = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _shortWeekdayNames = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _shortMonthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String formatFullDate(DateTime date) {
    return '${_weekdayNames[date.weekday - 1]}, ${date.day} '
        '${_monthNames[date.month - 1]}';
  }

  static String formatShortDate(DateTime date) {
    return '${date.day} ${_shortMonthNames[date.month - 1]}';
  }

  static String weekdayShortName(int weekday) {
    if (weekday < 1 || weekday > 7) return '';
    return _shortWeekdayNames[weekday - 1];
  }

  static String formatTime(int hour, int minute) {
    return '${formatHour(hour)}:${_twoDigits(minute)} ${period(hour)}';
  }

  static String formatTimeWithoutPeriod(int hour, int minute) {
    return '${formatHour(hour)}:${_twoDigits(minute)}';
  }

  static int formatHour(int hour) {
    final twelveHour = hour % 12;
    return twelveHour == 0 ? 12 : twelveHour;
  }

  static String period(int hour) => hour < 12 ? 'AM' : 'PM';

  static String dayLabel(DateTime occurrence, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(occurrence.year, occurrence.month, occurrence.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Tomorrow';
    }
    if (difference > 1 && difference < 7) {
      return _weekdayNames[occurrence.weekday - 1];
    }
    return formatShortDate(occurrence);
  }

  static String daysSummary(Iterable<int> repeatDays) {
    if (repeatDays.isEmpty) {
      return 'Once';
    }

    final days = repeatDays.toSet()..removeWhere((day) => day < 1 || day > 7);
    if (days.isEmpty) {
      return 'Once';
    }

    if (days.length == 7) {
      return 'Every day';
    }
    if (days.length == 5 && days.containsAll(const <int>[1, 2, 3, 4, 5])) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.containsAll(const <int>[6, 7])) {
      return 'Weekends';
    }

    final sortedDays = days.toList()..sort();
    return sortedDays.map((day) => _shortWeekdayNames[day - 1]).join(', ');
  }

  static DateTime? nextOccurrence(AlarmModel alarm, DateTime from) {
    if (!alarm.enabled) {
      return null;
    }

    if (alarm.repeatDays.isEmpty) {
      final todayAtTime = DateTime(
        from.year,
        from.month,
        from.day,
        alarm.hour,
        alarm.minute,
      );
      return todayAtTime.isAfter(from)
          ? todayAtTime
          : todayAtTime.add(const Duration(days: 1));
    }

    for (var offset = 0; offset <= 7; offset++) {
      final candidate = DateTime(
        from.year,
        from.month,
        from.day + offset,
        alarm.hour,
        alarm.minute,
      );
      if (alarm.repeatDays.contains(candidate.weekday) &&
          candidate.isAfter(from)) {
        return candidate;
      }
    }
    return null;
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
