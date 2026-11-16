# Release & Google Play Store Guide — Smart Alarm

## 1. Current Build & Identity Configuration

- **App Name:** `Smart Alarm`
- **Application ID:** `com.jihan.dreamalarm.smart_alarm`
- **Version:** `1.0.0+1` (`versionName: 1.0.0`, `versionCode: 1` configured in `pubspec.yaml`)
- **Java / Kotlin Target:** `JVM_17`
- **Release Optimization:** R8 minification (`isMinifyEnabled = true`), resource shrinking (`isShrinkResources = true`), and `android/app/proguard-rules.pro` enabled in `android/app/build.gradle.kts`

## 2. Signing Configuration (Upload Keystore)

`android/app/build.gradle.kts` loads release signing credentials from `android/key.properties` when present. If `android/key.properties` is absent, local builds fall back to debug signing so developers can test release compilation locally — **never upload a debug-signed artifact to Google Play**.

### Generate a Production Upload Keystore

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Create `android/key.properties`

Copy `android/key.properties.example` to `android/key.properties` and fill in your keystore path and passwords:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=upload-keystore.jks
```

> **Security:** `.gitignore` already excludes `*.jks`, `*.keystore`, `*.p12`, `key.properties`, and `/android/key.properties`. Never commit signing keys or passwords to version control.

## 3. R8 / ProGuard Rules

`android/app/proguard-rules.pro` preserves:

- Flutter embedding & `io.flutter.plugins.**`
- Native Kotlin alarm components under `com.jihan.dreamalarm.smart_alarm.**`
- Gson generic `TypeToken`, `Signature`, and annotated fields used by `AlarmStorage`

Always test release APKs/AABs after modifying models serialized by `Gson` or platform channel signatures in `MainActivity.kt`.

## 4. Pre-Release Verification Commands

Run all checks before creating store artifacts:

```bash
dart format --output=none --set-exit-if-changed .
flutter pub get
flutter analyze
flutter test
```

## 5. Building Release Artifacts

1. **Debug APK (QA / internal verification):**
   ```bash
   flutter build apk --debug
   ```
   Output: `build/app/outputs/flutter-apk/app-debug.apk`

2. **Release APK (side-load verification with R8 enabled):**
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

3. **Release App Bundle (Google Play upload format):**
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

## 6. Version Bumping

Before each new Play Store upload, increment both `versionName` and `versionCode` in `pubspec.yaml`:

```yaml
version: 1.0.1+2
```

## 7. Play Store Pre-Submission Checklist

- [ ] Real upload keystore configured in `android/key.properties` (not debug-signed).
- [ ] `versionCode` incremented in `pubspec.yaml`.
- [ ] Privacy Policy URL hosted (from `PRIVACY_POLICY.md`) and entered in Play Console.
- [ ] Data Safety form completed (no off-device data collection or sharing).
- [ ] Sensitive permissions declared (`USE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`; see [ANDROID_PERMISSIONS.md](ANDROID_PERMISSIONS.md)).
- [ ] Verified on a physical Android device (Android 12/13/14+): exact alarm trigger while locked/idle, mission audio pause/30s resume/5m limit, Dismiss gate, reboot reschedule, and notification actions.
