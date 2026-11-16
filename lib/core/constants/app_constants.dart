abstract final class AppConstants {
  static const String appName = 'Smart Alarm';
  static const String appDescription =
      'A mission-based alarm that helps heavy sleepers wake up with focus.';
  static const String appVersion = '1.0.0';
  static const String defaultAlarmLabel = 'Alarm';

  static const int maxAlarmLabelLength = 40;

  static const List<int> snoozeOptions = <int>[5, 10, 15, 20];

  static const double pageMaxWidth = 640;
  static const double horizontalPadding = 20;
  static const double cardRadius = 16;
  static const double sheetRadius = 18;
  static const double dialogRadius = 18;
  static const double fieldRadius = 14;
  static const double buttonRadius = 14;
  static const double smallRadius = 12;
}
