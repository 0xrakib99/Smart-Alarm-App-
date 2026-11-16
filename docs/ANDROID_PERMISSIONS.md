# Android Permissions & Platform Behavior — Smart Alarm

This document explains every Android permission declared in `android/app/src/main/AndroidManifest.xml`, how it behaves across Android versions, fallback handling when denied, OEM/platform limits, and Google Play Console declaration requirements.

## 1. Declared Manifest Permissions

| Permission | Purpose in Smart Alarm | User Action Required |
| --- | --- | --- |
| `android.permission.SCHEDULE_EXACT_ALARM` | Allows exact alarm scheduling via `AlarmManager` on Android 12+ (API 31+) when user approval applies. | System settings toggle (`Alarms & reminders`) on affected Android versions. |
| `android.permission.USE_EXACT_ALARM` | Alarm-clock class exact alarm scheduling permission for Android 13+ (API 33+) alarm clock applications. | Play Console Alarm Clock declaration required. |
| `android.permission.POST_NOTIFICATIONS` | Required on Android 13+ (API 33+) to show active alarm foreground notifications and full-screen notifications. | Runtime notification prompt (`PermissionService` / `PermissionsScreen`). |
| `android.permission.USE_FULL_SCREEN_INTENT` | Allows launching `FullScreenAlarmActivity` on top of the lock screen when an alarm fires. | Automatically granted on older versions; requires special app access check (`canUseFullScreenIntent()`) and Settings flow on Android 14+ (API 34+). |
| `android.permission.FOREGROUND_SERVICE` | Runs `AlarmService` reliably in the foreground while an alarm is ringing or paused during a mission. | Granted at install time. |
| `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Declares foreground service type for reliable alarm ringtone playback on Android 14+ (API 34+). | Granted at install time; requires Play Console foreground service declaration. |
| `android.permission.WAKE_LOCK` | Keeps CPU/screen awake during alarm trigger and mission execution until Dismiss is completed. | Granted at install time. |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Enables `BootReceiver` to re-register all active alarms after device reboot (`BOOT_COMPLETED`) and app update (`MY_PACKAGE_REPLACED`). | Granted at install time. |
| `android.permission.VIBRATE` | Powers alarm vibration patterns via `AlarmVibrator` (`VibrationAttributes.USAGE_ALARM` on API 33+). | Granted at install time. |

> **Privacy Note:** Smart Alarm does **not** declare `INTERNET`, Location, Camera, Microphone, Contacts, or `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.

## 2. Permission Flow & Fallbacks

- `PermissionService` listens to app lifecycle resume events (`WidgetsBindingObserver`) and updates live permission states whenever the user returns from Android system settings.
- `MainActivity` exposes:
  - `requestFullScreenIntentPermission` -> opens `Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT` on Android 14+ (API 34+).
  - `openAppSettings` -> opens `Settings.ACTION_APPLICATION_DETAILS_SETTINGS`.
- **If `POST_NOTIFICATIONS` is denied**: Full-screen notification delivery and ongoing alarm status visibility are degraded on Android 13+. `PermissionsScreen` highlights the missing status and guides the user to grant it.
- **If `USE_FULL_SCREEN_INTENT` is denied on Android 14+**: Alarms fall back to high-priority notification presentation rather than opening immediately over another app/lock screen; `MainActivity` accurately reports `canUseFullScreenIntent()` to `PermissionsScreen`.
- **If exact alarm scheduling is denied/unavailable**: `AlarmNativeService.scheduleAlarm` returns `false`, `CreateAlarmController` surfaces a warning (`scheduleWarning`), and `HomeController` reverts the enabled toggle so the UI never displays a false scheduled state.
- **If audio asset playback fails**: `AlarmAudioPlayer.play()` returns `false`, and `AlarmService` propagates an error callback to `MainActivity.notifyAlarmError(...)` and surfaces it on the active alarm UI (`AlarmRingingScreen`) and notification.

## 3. Honest Android Platform & OEM Limitations

Because Smart Alarm is a standard user-installed Android app (not a device-owner/kiosk MDM app), Android enforces the following boundaries:

1. **System Hardware & Navigation Buttons**: Cannot universally intercept or disable the device Power button, Home button, Recents gesture, or OS-level volume sliders.
2. **Force Stop**: If the user manually triggers **Force Stop** in Android System Settings, Android halts all background receivers and cancels pending `AlarmManager` broadcasts until the user manually reopens the app.
3. **OEM Battery Optimizers**: Some device manufacturers (e.g., Xiaomi/MIUI, Samsung, Huawei, Oppo/ColorOS, Vivo) apply aggressive background restrictions even for alarm apps; users may need to exclude Smart Alarm from OEM battery savers manually in Android Settings.

## 4. Google Play Console Declarations Required

Before publishing a release build to Google Play:

1. **Exact Alarm Permission (`USE_EXACT_ALARM`)**: Declare Smart Alarm as an **Alarm clock / Timer** core functionality app in Play Console Policy declarations.
2. **Full-Screen Intent (`USE_FULL_SCREEN_INTENT`)**: Declare alarm clock full-screen notification eligibility (required for Android 14+ Play Store target policies).
3. **Foreground Service (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`)**: Provide explanation/video showing `AlarmService` playing alarm audio while active until user dismisses after mission completion.
4. **Data Safety Form**: Declare that Smart Alarm collects and shares zero user data off-device.
