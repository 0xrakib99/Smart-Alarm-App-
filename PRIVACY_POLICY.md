# Privacy Policy — Smart Alarm

**Application ID:** `com.jihan.dreamalarm.smart_alarm`  
**Effective Date:** 2026-11-12

Smart Alarm is an offline, local-first alarm clock application. We respect your privacy and designed the application so that your alarms, mission history, and preferences remain on your device.

## 1. Data Stored Locally on Your Device

Smart Alarm stores only the data required for core alarm clock functionality in local device storage (`GetStorage` and Android `SharedPreferences`):

- **Alarm Schedules & Configuration**: Alarm times, labels, repeat weekdays, enabled states, selected sound, vibration settings, and mission configurations.
- **Alarm History & Statistics**: Completion statuses (`Completed`, `Snoozed`, `Missed`, `Cancelled`), mission durations, difficulty levels, and wake-up streak calculations.
- **Application Preferences**: Theme preference (Light/Dark) and volume/audio preferences.

All such data stays locally on your device.

## 2. No Network Transmission, Analytics, or Third-Party Tracking

- **No Internet Permission**: The Android manifest (`AndroidManifest.xml`) does not request `INTERNET` permission.
- **No Cloud Backup**: Android automatic cloud backup is explicitly disabled (`android:allowBackup="false"`).
- **No Analytics or Advertising SDKs**: Smart Alarm does not include telemetry, crash analytics trackers, ad networks, or third-party data collection SDKs.

## 3. Manual Backup Export & Import

If you choose to use the manual backup feature in Settings, Smart Alarm generates a local JSON backup string that you can copy/export and later paste/import on a device. You are solely responsible for where you save or share exported backup text.

## 4. Device Sensors & Permissions

- **Accelerometer (`sensors_plus`)**: Used exclusively in real time during active Shake missions to detect shake gestures. Sensor readings are never recorded, stored, or transmitted.
- **System Permissions**: Permissions such as Exact Alarms, Notifications, Full-Screen Intent, Wake Lock, Vibration, Boot Completed, and Foreground Service are used solely to schedule and present reliable alarms. See [docs/ANDROID_PERMISSIONS.md](docs/ANDROID_PERMISSIONS.md) for full details.

## 5. Data Deletion

You can delete individual alarms, delete individual history entries, clear all alarm history within the app, or uninstall Smart Alarm to remove all locally stored application data.
