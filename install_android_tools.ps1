# Android SDK Command Line Tools Installer for FlowPaisa
# This script downloads and installs Android SDK command line tools

$sdkPath = "E:\Users\Abdul.Wahid\AppData\Local\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools\latest"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android SDK Command Line Tools Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if SDK path exists
if (-not (Test-Path $sdkPath)) {
    Write-Host "ERROR: Android SDK path not found: $sdkPath" -ForegroundColor Red
    Write-Host "Please install Android Studio first or set up Android SDK manually." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Android SDK found at: $sdkPath" -ForegroundColor Green

# Create cmdline-tools directory
if (-not (Test-Path "$sdkPath\cmdline-tools")) {
    New-Item -ItemType Directory -Path "$sdkPath\cmdline-tools" -Force | Out-Null
    Write-Host "✓ Created cmdline-tools directory" -ForegroundColor Green
}

# Download command line tools
Write-Host ""
Write-Host "Downloading Android Command Line Tools..." -ForegroundColor Yellow
Write-Host "This may take a few minutes (~100MB download)..." -ForegroundColor Yellow
Write-Host ""

$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zipPath = "$env:TEMP\android-cmdline-tools.zip"

try {
    # Download using Invoke-WebRequest
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "✓ Download completed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download command line tools" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually from:" -ForegroundColor Yellow
    Write-Host "https://developer.android.com/studio#command-tools" -ForegroundColor Cyan
    exit 1
}

# Extract zip file
Write-Host ""
Write-Host "Extracting command line tools..." -ForegroundColor Yellow

if (Test-Path $cmdlineToolsPath) {
    Remove-Item -Path $cmdlineToolsPath -Recurse -Force
}

# Extract to temp location first
$tempExtractPath = "$env:TEMP\android-cmdline-tools-temp"
if (Test-Path $tempExtractPath) {
    Remove-Item -Path $tempExtractPath -Recurse -Force
}

Expand-Archive -Path $zipPath -DestinationPath $tempExtractPath -Force

# Move to correct location (cmdline-tools zip contains a 'cmdline-tools' folder)
$extractedFolder = Get-ChildItem -Path $tempExtractPath -Directory | Select-Object -First 1
if ($extractedFolder.Name -eq "cmdline-tools") {
    Move-Item -Path "$tempExtractPath\cmdline-tools\*" -Destination "$sdkPath\cmdline-tools\latest" -Force
} else {
    New-Item -ItemType Directory -Path $cmdlineToolsPath -Force | Out-Null
    Move-Item -Path "$tempExtractPath\*" -Destination $cmdlineToolsPath -Force
}

# Cleanup
Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✓ Extraction completed" -ForegroundColor Green

# Verify installation
if (Test-Path "$cmdlineToolsPath\bin\sdkmanager.bat") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Command Line Tools Installed Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Location: $cmdlineToolsPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Add to PATH: $cmdlineToolsPath\bin" -ForegroundColor White
    Write-Host "2. Run: flutter doctor --android-licenses" -ForegroundColor White
    Write-Host "3. Run: flutter doctor" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: Installation verification failed" -ForegroundColor Red
    Write-Host "sdkmanager.bat not found at expected location" -ForegroundColor Red
    exit 1
}


