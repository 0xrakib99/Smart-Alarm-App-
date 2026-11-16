import 'package:get/get.dart';
import 'package:smart_alarm/app/bindings/alarm_ringing_binding.dart';
import 'package:smart_alarm/app/bindings/create_alarm_binding.dart';
import 'package:smart_alarm/app/bindings/history_binding.dart';
import 'package:smart_alarm/app/bindings/home_binding.dart';
import 'package:smart_alarm/app/bindings/mission_bindings.dart';
import 'package:smart_alarm/app/bindings/mission_selection_binding.dart';
import 'package:smart_alarm/app/bindings/splash_binding.dart';
import 'package:smart_alarm/app/bindings/statistics_binding.dart';
import 'package:smart_alarm/app/routes/app_routes.dart';
import 'package:smart_alarm/features/alarm/presentation/alarm_ringing_screen.dart';
import 'package:smart_alarm/features/alarm/presentation/create_alarm_screen.dart';
import 'package:smart_alarm/features/history/presentation/history_screen.dart';
import 'package:smart_alarm/features/home/presentation/home_screen.dart';
import 'package:smart_alarm/features/missions/color_sequence/screens/color_sequence_screen.dart';
import 'package:smart_alarm/features/missions/math/screens/math_mission_screen.dart';
import 'package:smart_alarm/features/missions/memory/screens/memory_mission_screen.dart';
import 'package:smart_alarm/features/missions/presentation/mission_selection_screen.dart';
import 'package:smart_alarm/features/missions/puzzle/screens/puzzle_mission_screen.dart';
import 'package:smart_alarm/features/missions/shake/screens/shake_mission_screen.dart';
import 'package:smart_alarm/features/missions/tap/screens/tap_mission_screen.dart';
import 'package:smart_alarm/features/missions/typing/screens/typing_mission_screen.dart';
import 'package:smart_alarm/features/missions/word_scramble/screens/word_scramble_screen.dart';
import 'package:smart_alarm/features/permissions/presentation/permissions_screen.dart';
import 'package:smart_alarm/features/settings/presentation/settings_screen.dart';
import 'package:smart_alarm/features/splash/presentation/splash_screen.dart';
import 'package:smart_alarm/features/statistics/presentation/statistics_screen.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 240),
    ),
    GetPage<dynamic>(
      name: AppRoutes.createAlarm,
      page: () => const CreateAlarmScreen(),
      binding: CreateAlarmBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage<dynamic>(
      name: AppRoutes.missions,
      page: () => const MissionSelectionScreen(),
      binding: MissionSelectionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.mathMission,
      page: () => const MathMissionScreen(),
      binding: MathMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.tapMission,
      page: () => const TapMissionScreen(),
      binding: TapMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.memoryMission,
      page: () => const MemoryMissionScreen(),
      binding: MemoryMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.puzzleMission,
      page: () => const PuzzleMissionScreen(),
      binding: PuzzleMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.shakeMission,
      page: () => const ShakeMissionScreen(),
      binding: ShakeMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.wordScrambleMission,
      page: () => const WordScrambleScreen(),
      binding: WordScrambleMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.colorSequenceMission,
      page: () => const ColorSequenceScreen(),
      binding: ColorSequenceMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.typingMission,
      page: () => const TypingMissionScreen(),
      binding: TypingMissionBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.alarmRinging,
      page: () => const AlarmRingingScreen(),
      binding: AlarmRingingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage<dynamic>(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 220),
    ),
    GetPage<dynamic>(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.statistics,
      page: () => const StatisticsScreen(),
      binding: StatisticsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
    GetPage<dynamic>(
      name: AppRoutes.permissions,
      page: () => const PermissionsScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 260),
    ),
  ];
}
