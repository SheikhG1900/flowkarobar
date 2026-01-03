# Install Android Command Line Tools

## Method 1: Using Android Studio (Easiest) ⭐

1. **Open Android Studio**

2. **Open SDK Manager:**
   - Click **More Actions** (or **Configure** if on welcome screen)
   - Select **SDK Manager**
   - Or: **Tools → SDK Manager**

3. **Install Command Line Tools:**
   - Go to **SDK Tools** tab
   - Check **Android SDK Command-line Tools (latest)**
   - Click **Apply** → **OK**
   - Wait for installation to complete

4. **Verify Installation:**
   ```bash
   flutter doctor
   ```

5. **Accept Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   - Type `y` for each license agreement

---

## Method 2: Manual Download (If Method 1 doesn't work)

1. **Download Command Line Tools:**
   - Visit: https://developer.android.com/studio#command-tools
   - Under "Command line tools only", download **Windows** version

2. **Extract:**
   - Extract the ZIP file
   - You'll see a `cmdline-tools` folder inside

3. **Install:**
   - Copy the contents of `cmdline-tools` folder
   - Paste to: `E:\Users\Abdul.Wahid\AppData\Local\Android\Sdk\cmdline-tools\latest\`
   - Final structure should be:
     ```
     E:\Users\Abdul.Wahid\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
     ```

4. **Accept Licenses:**
   ```bash
   flutter doctor --android-licenses
   ```

---

## After Installation

Run these commands to verify:

```bash
# Check status
flutter doctor

# Should show:
# ✅ Android toolchain - develop for Android devices
```

Then create an Android emulator and run your app!


