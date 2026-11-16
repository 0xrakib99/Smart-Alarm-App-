# Smart Alarm

A mission-based Android alarm application built with Flutter, GetX, Clean Architecture, and native Android Kotlin alarm services.

## Overview

Smart Alarm enforces active alarm dismissal through mandatory wake-up missions while managing exact scheduling, lock-screen presentation, background playback, alarm history, wake-up streaks, and local JSON backup/restore without remote servers or telemetry.

## Core Features

- **Exact Alarm Scheduling**: One-time and weekday-recurring alarms persisted locally and restored across app restarts, device reboots (`BOOT_COMPLETED`), and app updates (`MY_PACKAGE_REPLACED`) using native Android `AlarmManager` (`setAlarmClock`) and `BootReceiver`.
- **Strict Alarm Mode & Full-Screen Presentation**: Native foreground service (`AlarmService`) with media playback audio focus, wake-lock handling, vibration (`AlarmVibrator`), high-priority ongoing notification, and lock-screen `FullScreenAlarmActivity`.
- **Mandatory Wake-Up Missions**:
  - **Math** (`MathMissionController`)
  - **Tap** (`TapMissionController`)
  - **Memory** (`MemoryMissionController`)
  - **Puzzle** (`PuzzleMissionController`)
  - **Shake** (`ShakeMissionController` backed by `sensors_plus`)
  - Supports `Easy`, `Medium`, and `Hard` difficulty levels.
  - Dismissing an active alarm is blocked until all required missions are completed; ringtone pauses temporarily during active mission attempts with inactivity and total-duration resume safeguards.
- **Alarm History & Statistics**: Real-time statistics and daily wake-up streaks computed strictly from locally persisted alarm history (`Completed`, `Snoozed`, `Missed`, `Cancelled`) with date/status filters and sort controls.
- **Theme & Accessibility**: Minimal Light Mode default with full Dark Mode support (`#582493` primary accent), responsive layouts, and zero fake data.
- **Local Backup & Recovery**: Manual JSON backup export/import with schema/payload validation and duplicate ID protection.

## Technology Stack

- **Flutter / Dart**: Flutter `3.44.9` / Dart SDK `^3.12.2`
- **State Management, DI & Routing**: `get: ^4.7.3` (GetX)
- **Local Persistence**: `get_storage: ^2.1.1` (+ Android `SharedPreferences` via `AlarmStorage` for native service recovery)
- **Sensors**: `sensors_plus: ^7.1.1`
- **Native Android**: Kotlin (`2.3.20`), Android Gradle Plugin (`9.0.1`), Gradle (`9.1.0`), `androidx.core:core-ktx:1.13.1`, `androidx.appcompat:appcompat:1.6.1`, `com.google.code.gson:gson:2.10.1`

## Project Structure

```text
lib/
  app/
    routes/          # GetX route definitions (app_pages.dart)
    theme/           # Color palette and light/dark theme tokens
  core/
    constants/       # App constants, sound definitions, dialogs, feedback helpers
    services/        # Native alarm bridge, state, permissions, backup, local storage
  data/
    providers/       # Local GetStorage providers for alarms, history, settings
    repositories/    # Repository layer isolating data access
  features/
    splash/          # Launch screen & startup routing
    permissions/     # Runtime permission status & native settings launchers
    home/            # Alarm list, toggle, overview
    alarm/           # Create/edit alarm, mission selection wiring, active alarm screen
    missions/        # Math, Tap, Memory, Puzzle, Shake mission modules
    history/         # Alarm history, filters, streak & statistics calculators
    settings/        # Theme, volume, backup export/import
android/
  app/
    proguard-rules.pro
    key.properties.example
    src/main/
      AndroidManifest.xml
      kotlin/com/jihan/dreamalarm/smart_alarm/
        MainActivity.kt
        AlarmService.kt
        AlarmAudioPlayer.kt
        AlarmVibrator.kt
        AlarmManagerHelper.kt
        AlarmReceiver.kt
        AlarmStorage.kt
        BootReceiver.kt
        FullScreenAlarmActivity.kt
assets/
  siren_sound.mp3
docs/
  ANDROID_PERMISSIONS.md
  RELEASE_GUIDE.md
```

## Setup & Prerequisites

- Flutter SDK matching Dart `^3.12.2` (verified with Flutter `3.44.9`)
- Android SDK Platform 34+ (Java 17 toolchain)
- An Android physical device or emulator for runtime alarm, lock-screen, and sensor testing

### Install Dependencies

```bash
flutter pub get
```

### Run Code Quality & Automated Tests

```bash
dart format .
flutter analyze
flutter test
```

### Build APK / App Bundle

- Debug APK:
  ```bash
  flutter build apk --debug
  ```
- Release APK (configure `android/key.properties` first for upload signing; see [docs/RELEASE_GUIDE.md](docs/RELEASE_GUIDE.md)):
  ```bash
  flutter build apk --release
  ```
- Release Android App Bundle (`.aab`):
  ```bash
  flutter build appbundle --release
  ```

## Documentation

- [Privacy Policy](PRIVACY_POLICY.md)
- [Android Permissions Guide](docs/ANDROID_PERMISSIONS.md)
- [Release & Play Store Guide](docs/RELEASE_GUIDE.md)
