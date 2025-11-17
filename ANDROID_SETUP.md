# Android Build Setup Guide for Helix

Complete setup requirements for building the Helix Flutter app on Android devices.

---

## Prerequisites

### 1. Android SDK
- **Minimum SDK**: API 28 (Android 9.0 Pie)
- **Target SDK**: Latest (configured automatically by Flutter)
- **Compile SDK**: API 34 or higher

### 2. Build Tools Versions
- **Android Gradle Plugin (AGP)**: 8.3.0
- **Gradle**: 8.4
- **Kotlin**: 2.1.0
- **Google Services**: 4.4.0

---

## Configuration Files

### 1. `android/settings.gradle`

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.3.0" apply false
    id "com.google.gms.google-services" version "4.4.0" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

**Why these versions?**
- AGP 8.3.0: Fixes Java 21 compatibility issues (minimum 8.2.1 required)
- Kotlin 2.1.0: Required for Google Play Services libraries compatibility
- Google Services 4.4.0: Latest stable for Firebase integration

---

### 2. `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
```

**Why Gradle 8.4?**
- Minimum version required by Android Gradle Plugin 8.3.0
- Supports latest Kotlin features

---

### 3. `android/app/build.gradle`

```gradle
android {
    namespace = "com.helix.helix"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.helix.helix"
        minSdk = 28  // Android 9.0 (Pie)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

**Why minSdk 28?**
- Firebase Auth requires minimum API 23
- Android 9.0 (2018) provides modern baseline
- Covers 95%+ of active Android devices
- Better security and performance features

---

## Firebase & Google Sign-In Setup

### Required Files
- ✅ `android/app/google-services.json` (from Firebase Console)

### Step-by-Step Setup

#### 1. Get Your Debug SHA-1 Fingerprint

```bash
cd helix-app/android
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android | grep SHA1
```

**Expected Output:**
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

Copy this fingerprint.

---

#### 2. Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **Helix** project
3. Click **⚙️ Settings** → **Project settings**
4. Scroll to **Your apps** section
5. Find your Android app (`com.helix.helix`)
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

**Why is this needed?**
- Verifies your app is authorized to use Google Sign-In
- Required for Firebase Authentication on Android
- Different fingerprints needed for debug and release builds

---

#### 3. Download Updated google-services.json

After adding the SHA-1 fingerprint:

1. Still in Firebase Console → **Project Settings**
2. Under your Android app section
3. Click **Download google-services.json**
4. Replace the existing file:

```bash
# From Downloads folder
cp ~/Downloads/google-services.json helix-app/android/app/google-services.json
```

**Important:** This file is automatically updated by Firebase when you add SHA-1 fingerprints.

---

## Common Build Errors & Solutions

### Error 1: minSdkVersion Too Low

```
Error: uses-sdk:minSdkVersion 21 cannot be smaller than version 23
```

**Solution:**
Update `android/app/build.gradle`:
```gradle
minSdk = 28  // Changed from 21
```

---

### Error 2: Gradle Version Too Old

```
Error: Minimum supported Gradle version is 8.4. Current version is 8.3
```

**Solution:**
Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
```

---

### Error 3: Kotlin Version Incompatible

```
Error: Module was compiled with Kotlin 2.1.0, expected version is 1.9.0
```

**Solution:**
Update `android/settings.gradle`:
```gradle
id "org.jetbrains.kotlin.android" version "2.1.0" apply false
```

---

### Error 4: Google Sign-In Failed (PlatformException)

```
PlatformException: sign_in_failed
```

**Solution:**
1. Get debug SHA-1 fingerprint (see above)
2. Add to Firebase Console
3. Download new `google-services.json`
4. Replace file in `android/app/`
5. Run `flutter clean && flutter run`

---

## Release Build Setup (Future)

When building for release, you'll need:

### 1. Generate Release Keystore

```bash
keytool -genkey -v -keystore release-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias helix-release
```

### 2. Get Release SHA-1

```bash
keytool -list -v \
  -keystore release-keystore.jks \
  -alias helix-release | grep SHA1
```

### 3. Add Release SHA-1 to Firebase

Follow same steps as debug, but add the **release** SHA-1 fingerprint.

### 4. Configure Signing in build.gradle

```gradle
android {
    signingConfigs {
        release {
            storeFile file('release-keystore.jks')
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias 'helix-release'
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## Device Requirements

### Minimum Device Requirements
- **Android Version**: 9.0 (Pie) or higher
- **API Level**: 28+
- **Released**: August 2018

### Supported Devices
- Google Pixel series (Pixel 3 and newer)
- Samsung Galaxy (S9 and newer)
- OnePlus (6 and newer)
- Most devices from 2018 onwards

### Your Test Device
- **Pixel 7**: Android 14/15/16 ✅
- **API Level**: 34+ ✅
- **Fully Compatible** ✅

---

## Build Commands

### Clean Build
```bash
cd helix-app
flutter clean
flutter pub get
flutter run
```

### Check Connected Devices
```bash
flutter devices
```

### Run on Specific Device
```bash
flutter run -d <device-id>
```

### Build Release APK
```bash
flutter build apk --release
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

---

## Verification Checklist

Before running `flutter run`, verify:

- [ ] Android Studio installed with SDK tools
- [ ] `minSdk = 28` in `build.gradle`
- [ ] Gradle 8.4 in `gradle-wrapper.properties`
- [ ] AGP 8.3.0 in `settings.gradle`
- [ ] Kotlin 2.1.0 in `settings.gradle`
- [ ] Debug SHA-1 added to Firebase Console
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] Device connected and authorized for USB debugging
- [ ] `flutter doctor` shows no Android issues

---

## Troubleshooting

### Gradle Build Fails
```bash
cd helix-app
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Dependency Issues
```bash
cd helix-app/android
./gradlew app:dependencies
```

### Cache Issues
```bash
# Clear Flutter cache
flutter clean

# Clear Gradle cache
rm -rf ~/.gradle/caches/

# Rebuild
flutter pub get
flutter run
```

### USB Debugging Not Working
1. Enable **Developer Options** on device (tap Build Number 7 times)
2. Enable **USB Debugging** in Developer Options
3. Enable **Install via USB**
4. Reconnect device and allow when prompted

---

## Quick Reference

| Component | Version | Why? |
|-----------|---------|------|
| minSdk | 28 | Firebase requirement + modern baseline |
| AGP | 8.3.0 | Java 21 compatibility |
| Gradle | 8.4 | AGP 8.3.0 requirement |
| Kotlin | 2.1.0 | Google Play Services compatibility |
| Google Services | 4.4.0 | Latest stable Firebase plugin |

---

## Additional Resources

- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
- [Android Studio Setup](https://developer.android.com/studio)
- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)

---

**Last Updated:** Based on build errors encountered during initial setup

**Tested On:**
- Pixel 7 (Android 14/15/16)
- MacBook Pro M1 (2021)
- Flutter 3.27.1
