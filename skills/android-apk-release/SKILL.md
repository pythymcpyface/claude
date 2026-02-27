# Android APK Build & GitHub Release

Build Android APK from Capacitor project, test on emulator, and create GitHub release.

## When to Use

- User asks to "build APK", "release to Android", "deploy to phone"
- User wants to test Android app on emulator
- User wants to create a GitHub release with APK

## Prerequisites

- Capacitor project with `android` platform
- Android SDK at `/usr/local/share/android-commandlinetools`
- GitHub CLI (`gh`) authenticated
- Emulator AVD configured (e.g., `Pixel_8_API_34`)

## Workflow

### 1. Build Web App & Sync Capacitor

```bash
npm run build
npx cap sync android
```

### 2. Build Android APK

```bash
cd android
./gradlew assembleDebug
```

APK location: `android/app/build/outputs/apk/debug/app-debug.apk`

### 3. Test on Emulator (Optional)

```bash
# List available emulators
/usr/local/share/android-commandlinetools/emulator/emulator -list-avds

# Start emulator (background)
/usr/local/share/android-commandlinetools/emulator/emulator -avd Pixel_8_API_34 -no-snapshot-load &

# Wait for boot
/usr/local/share/android-commandlinetools/platform-tools/adb wait-for-device
/usr/local/share/android-commandlinetools/platform-tools/adb shell getprop sys.boot_completed

# Install and run
/usr/local/share/android-commandlinetools/platform-tools/adb install -r ./app/build/outputs/apk/debug/app-debug.apk
/usr/local/share/android-commandlinetools/platform-tools/adb shell am start -n com.<package>.game/.MainActivity

# Check for crashes
/usr/local/share/android-commandlinetools/platform-tools/adb logcat -d | grep -E "AndroidRuntime|FATAL|Error"
```

### 4. Create GitHub Release

```bash
# Get current version
VERSION=$(cat package.json | grep '"version"' | cut -d'"' -f4)

# Create release (increment version as needed)
gh release create v${VERSION}-android \
  ./app/build/outputs/apk/debug/app-debug.apk \
  --title "v${VERSION} Android" \
  --notes "Release notes here"
```

## Common Issues

### Activity Class Not Found

**Error:** `Activity class {com.package/.MainActivity} does not exist.`

**Cause:** MainActivity.java package name doesn't match AndroidManifest.xml

**Fix:**
```bash
# Check MainActivity location
find android/app/src/main/java -name "MainActivity.java"

# Ensure package matches build.gradle applicationId
# Move/recreate MainActivity in correct directory:
mkdir -p android/app/src/main/java/com/<package>/game
# Update package declaration in MainActivity.java
```

### Package Service Not Ready

**Error:** `cmd: Can't find service: package`

**Cause:** Emulator not fully booted

**Fix:** Wait for `sys.boot_completed == 1`

### Old Package Name Remains

After renaming app/package:
1. Update `android/app/build.gradle` - `applicationId` and `namespace`
2. Update `android/app/src/main/res/values/strings.xml` - `app_name`, `package_name`
3. Update `android/app/src/main/AndroidManifest.xml` if needed
4. Move `MainActivity.java` to correct package directory
5. Remove old package directory: `rm -rf android/app/src/main/java/com/<oldpackage>`

## File Checklist

When renaming package:
- [ ] `android/app/build.gradle` - applicationId, namespace
- [ ] `android/app/src/main/res/values/strings.xml` - app_name, package_name, custom_url_scheme
- [ ] `android/app/src/main/java/com/<newpackage>/MainActivity.java` - package declaration
- [ ] `capacitor.config.ts` - appId
- [ ] Delete old `android/app/src/main/java/com/<oldpackage>/` directory

## Environment Paths

```bash
EMULATOR="/usr/local/share/android-commandlinetools/emulator/emulator"
ADB="/usr/local/share/android-commandlinetools/platform-tools/adb"
```
