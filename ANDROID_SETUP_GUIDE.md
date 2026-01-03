# Android Setup Guide for FlowPaisa

## Quick Setup Steps

### Option 1: Install Android Studio (Recommended - Easiest) ⭐

1. **Download Android Studio:**
   - Visit: https://developer.android.com/studio
   - Click "Download Android Studio"
   - Download the Windows installer (~1GB)

2. **Install Android Studio:**
   - Run the installer
   - Follow the installation wizard
   - **Important:** Make sure to install:
     - Android SDK
     - Android SDK Platform
     - Android Virtual Device (AVD)
     - Performance (Intel HAXM) - if you have Intel CPU

3. **First Launch Setup:**
   - Open Android Studio
   - It will automatically download required SDK components
   - Wait for "SDK Manager" to finish downloading

4. **Verify Installation:**
   ```bash
   flutter doctor
   ```

5. **Accept Android Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   - Type `y` for each license agreement

---

### Option 2: Manual SDK Setup (If you don't want Android Studio)

1. **Install Command Line Tools:**
   - Download from: https://developer.android.com/studio#command-tools
   - Extract to: `E:\Users\Abdul.Wahid\AppData\Local\Android\Sdk\cmdline-tools\latest`

2. **Install Required Components:**
   ```bash
   cd E:\Users\Abdul.Wahid\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
   .\sdkmanager.bat "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

3. **Accept Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```

---

## After Installation

### Create an Android Emulator:

1. **Open Android Studio**
2. **Tools → Device Manager**
3. **Create Device**
4. **Choose a device** (e.g., Pixel 5)
5. **Select System Image** (e.g., Android 13 - API 33)
6. **Finish**

### Run Your App:

```bash
# List available devices
flutter devices

# Run on Android emulator
flutter run -d android

# Or run on specific device
flutter run -d <device-id>
```

---

## Troubleshooting

### If `flutter doctor` still shows issues:

1. **Set ANDROID_HOME environment variable:**
   - Open System Properties → Environment Variables
   - Add new System Variable:
     - Name: `ANDROID_HOME`
     - Value: `E:\Users\Abdul.Wahid\AppData\Local\Android\Sdk`

2. **Add to PATH:**
   - Add to PATH: `%ANDROID_HOME%\platform-tools`
   - Add to PATH: `%ANDROID_HOME%\tools`
   - Add to PATH: `%ANDROID_HOME%\cmdline-tools\latest\bin`

3. **Restart terminal and run:**
   ```bash
   flutter doctor
   ```

---

## Current Status

✅ **What you have:**
- Flutter installed
- Android SDK partially installed (version 34.0.0)
- VS Code with Flutter extension

❌ **What's missing:**
- Android Studio (recommended)
- cmdline-tools
- Android licenses not accepted

---

## Next Steps

1. Install Android Studio (Option 1 above)
2. Run `flutter doctor --android-licenses`
3. Create an Android emulator
4. Run `flutter run` to test FlowPaisa!


