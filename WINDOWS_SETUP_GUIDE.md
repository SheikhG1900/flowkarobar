# Flowpaisa Windows Setup Guide

This guide covers running and building Flowpaisa on Windows desktop.

## Prerequisites

### 1. Flutter SDK

Flutter is installed at:

```
C:\flutter_github\flutter
```

Add to your **PATH** (recommended):

```
C:\flutter_github\flutter\bin
```

Verify:

```powershell
flutter doctor
```

### 2. Visual Studio (required for Windows builds)

Install **Visual Studio 2022** or **Build Tools 2022** with:

- Workload: **Desktop development with C++**
- Include all default components for that workload
- **Also required:** **C++ ATL for latest v143 build tools (x86 & x64)** — needed by `flutter_local_notifications_windows` and `flutter_secure_storage_windows`

Using winget:

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools --accept-package-agreements --accept-source-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.ATLMFC --includeRecommended"
```

If Build Tools is already installed, add ATL/MFC from an **elevated** PowerShell:

```powershell
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify `
  --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" `
  --add Microsoft.VisualStudio.Component.VC.ATLMFC `
  --passive --norestart
```

After installation, restart your terminal and run:

```powershell
flutter doctor
```

You should see `[✓] Visual Studio`.

### 3. Enable Windows desktop

```powershell
flutter config --enable-windows-desktop
```

## Run the app

From the project root:

```powershell
cd E:\work\github\cashbook
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

## Build release

```powershell
flutter build windows
```

Output: `build\windows\x64\runner\Release\flowpaisa.exe`

## Google Drive sign-in on Windows

Windows requires a **Web OAuth client ID** for Google Sign-In.

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (same one used for Android)
3. **APIs & Services → Credentials**
4. Create **OAuth 2.0 Client ID** → Application type: **Web application**
5. Add authorized redirect URI if prompted by your OAuth flow
6. Copy the client ID and set it in:

   `lib/features/backup/data/google_drive_service.dart`

   Replace:

   ```dart
   'YOUR_WINDOWS_CLIENT_ID.apps.googleusercontent.com'
   ```

## Premium on Windows

- In-app purchases are **not** available on Windows
- Purchase Premium on Android/iOS, then sign in with the same Google account on Windows
- Premium status is verified via the **Premium Token** stored in Google Drive `appDataFolder`

## Platform limitations on Windows

These mobile-only features are hidden or disabled on Windows:

| Feature | Status on Windows |
|---------|-------------------|
| Receipt scan (ML Kit) | Hidden |
| Import contacts from device | Disabled |
| In-app purchase | Not available (use Premium Token) |
| In-app update (Play Store) | Skipped |
| Voice add | Available (uses speech_to_text) |
| Google Drive backup/sync | Available (after OAuth setup) |
| Transactions, analytics, export | Available |

## Troubleshooting

### `Unable to find suitable Visual Studio toolchain`

Install Visual Studio Build Tools with the C++ workload (see above), then restart the terminal.

### `flutter` not recognized

Add `C:\flutter_github\flutter\bin` to your PATH or use the full path:

```powershell
C:\flutter_github\flutter\bin\flutter.bat run -d windows
```

### Google Sign-In fails on Windows

Ensure the Web OAuth client ID is configured in `google_drive_service.dart`.

### Build is slow the first time

The first Windows build compiles native C++ and can take several minutes.
