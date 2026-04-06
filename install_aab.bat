@echo off
set BUNDLETOOL_JAR=bundletool.jar
set ADB_PATH=C:\Users\Abdul.Wahid\AppData\Local\Android\Sdk\platform-tools\adb.exe
set AAB_PATH=build\app\outputs\bundle\release\app-release.aab
set OUTPUT_APKS=app.apks

echo [1/3] Generating universal APK set from AAB...
java -jar %BUNDLETOOL_JAR% build-apks --bundle="%AAB_PATH%" --output=%OUTPUT_APKS% --mode=universal --overwrite

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to generate APKs.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/3] Attempting to install to connected device...
echo (Note: If this fails with INSTALL_FAILED_UPDATE_INCOMPATIBLE, please uninstall the existing app first)
echo.

java -jar %BUNDLETOOL_JAR% install-apks --apks=%OUTPUT_APKS% --adb="%ADB_PATH%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Error: Installation failed. 
    echo Common reasons: 
    echo 1. Device not connected (run 'adb devices')
    echo 2. Existing app has different signature (Uninstall it first)
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/3] Success! The app has been installed.
pause
