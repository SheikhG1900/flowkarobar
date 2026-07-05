# deploy_windows.ps1
# Flowpaisa Windows Build, Package & Deploy Automation Script
# This script automates compiling, packaging with Inno Setup, committing/pushing to GitHub, creating a GitHub Release with the installer asset, and deploying to Firebase Hosting.

# Supported parameters:
#   -SkipRelease: Skips compiling, packaging, committing, and uploading to GitHub. Only deploys the website/version.json to Firebase.
#   -SkipBuild: Skips the Flutter build step (useful if you already compiled and just want to package/deploy).
#
# Examples:
#   .\deploy_windows.ps1                  <-- Full pipeline (Production Release)
#   .\deploy_windows.ps1 -SkipRelease     <-- Fast Website/Config Deploy (Testing)
#   .\deploy_windows.ps1 -SkipBuild       <-- Fast Packaging & Deploy

param (
    [switch]$SkipRelease,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

# Define Paths
$InnoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$InstallerScript = ".\windows_installer.iss"
$BuildDir = ".\build\windows\x64\runner\Release"
$SetupOutputName = "flowpaisa_setup.exe"
$WebsiteDir = ".\website"
$WebsiteDownloadsDir = "$WebsiteDir\downloads"

# Define Flutter Path (Fallback if not in global PATH)
$FlutterPath = "C:\flutter_github\flutter\bin\flutter.bat"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   Flowpaisa Windows Auto-Deploy Pipeline" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if ($SkipRelease) {
    Write-Host "ℹ️  [SkipRelease] Mode Active: Skipping Build, Packaging, and GitHub Release." -ForegroundColor Yellow
}
if ($SkipBuild -and !$SkipRelease) {
    Write-Host "ℹ️  [SkipBuild] Mode Active: Skipping Flutter Compilation." -ForegroundColor Yellow
}

# 1. Read version and build number from version.json
$VersionJsonPath = "$WebsiteDir\version.json"
$AppVersion = "1.0.0"
$BuildNumber = "58"

if (Test-Path $VersionJsonPath) {
    $jsonContent = Get-Content -Raw -Path $VersionJsonPath | ConvertFrom-Json
    $AppVersion = $jsonContent.version
    $BuildNumber = $jsonContent.buildNumber
    Write-Host "Detected Version: $AppVersion (Build: $BuildNumber)" -ForegroundColor Gray
} else {
    Write-Host "ERROR: version.json is missing from website folder!" -ForegroundColor Red
    exit 1
}

# 2. Build the Flutter Windows Release
if (!$SkipRelease -and !$SkipBuild) {
    Write-Host "`n[1/5] Building Flutter Windows Release..." -ForegroundColor Green

    # Check if flutter is available globally, otherwise use the specific path
    $FlutterCmd = Get-Command "flutter" -ErrorAction SilentlyContinue
    if ($FlutterCmd) {
        & flutter build windows --release
    } elseif (Test-Path $FlutterPath) {
        Write-Host "Using Flutter from: $FlutterPath" -ForegroundColor Gray
        & $FlutterPath build windows --release
    } else {
        Write-Error "Flutter SDK was not found in your system PATH or at '$FlutterPath'. Please configure it."
        exit 1
    }
} else {
    Write-Host "`n[1/5] Skipping Flutter Windows Release build step." -ForegroundColor Yellow
}

# 3. Package the Installer using Inno Setup
if (!$SkipRelease) {
    Write-Host "`n[2/5] Packaging Installer using Inno Setup..." -ForegroundColor Green

    # Check if ISCC.exe exists
    if (Test-Path $InnoSetupPath) {
        Write-Host "Found Inno Setup Compiler at: $InnoSetupPath" -ForegroundColor Gray
        & $InnoSetupPath $InstallerScript
    } else {
        # Try finding it in PATH
        $InnoSetupInPath = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
        if ($InnoSetupInPath) {
            Write-Host "Found Inno Setup Compiler in PATH: $($InnoSetupInPath.Source)" -ForegroundColor Gray
            & ISCC.exe $InstallerScript
        } else {
            Write-Host "WARNING: Inno Setup Compiler (ISCC.exe) was not found." -ForegroundColor Yellow
            Write-Host "Please install Inno Setup 6 (https://jrsoftware.org/isinfo.php) to package the app into an installer." -ForegroundColor Yellow
            Write-Host "Skipping installer packaging step..." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "`n[2/5] Skipping Inno Setup packaging step." -ForegroundColor Yellow
}

# 4. Copy Installer to Website Directory
if (!$SkipRelease) {
    Write-Host "`n[3/5] Copying installer and version.json to Website directory..." -ForegroundColor Green

    # Create downloads folder if it doesn't exist
    if (!(Test-Path $WebsiteDownloadsDir)) {
        New-Item -ItemType Directory -Force -Path $WebsiteDownloadsDir | Out-Null
    }

    # Check if the setup file was generated
    $GeneratedSetupPath = ".\Output\$SetupOutputName" # Default Inno Setup output directory is .\Output\
    if (Test-Path $GeneratedSetupPath) {
        Copy-Item -Path $GeneratedSetupPath -Destination "$WebsiteDownloadsDir\$SetupOutputName" -Force
        Write-Host "Successfully copied installer to website downloads folder." -ForegroundColor Gray
    } else {
        Write-Host "Skipping installer copying because the setup file was not found." -ForegroundColor Yellow
    }

    # Add a warning file to downloads folder to remind about Spark plan restrictions
    $ReadmeFile = "$WebsiteDownloadsDir\README_SPARK_PLAN.txt"
    if (!(Test-Path $ReadmeFile)) {
        "Note: Executable files (.exe) are forbidden on the Firebase Hosting Spark billing plan. This folder is ignored in firebase.json and the installer is hosted on GitHub Releases instead." | Out-File -FilePath $ReadmeFile -Force
    }
} else {
    Write-Host "`n[3/5] Skipping installer copying step." -ForegroundColor Yellow
}

# 5. Git Commit & Push to GitHub + Create GitHub Release
if (!$SkipRelease) {
    Write-Host "`n[4/5] Committing, pushing code, and creating GitHub Release..." -ForegroundColor Green

    $GitCmd = Get-Command "git" -ErrorAction SilentlyContinue
    if ($GitCmd) {
        # Get current branch name
        $BranchName = (git rev-parse --abbrev-ref HEAD).Trim()
        Write-Host "Current Git Branch: $BranchName" -ForegroundColor Gray

        # Stage all changes
        Write-Host "Staging changes..." -ForegroundColor Gray
        git add .

        # Commit changes with version info
        $CommitMessage = "Release version $AppVersion (Build $BuildNumber)"
        Write-Host "Committing changes with message: '$CommitMessage'..." -ForegroundColor Gray
        
        # Check if there are any changes to commit
        $Status = git status --porcelain
        if ($Status) {
            git commit -m $CommitMessage
            
            # Push to remote branch
            Write-Host "Pushing to GitHub (origin $BranchName)..." -ForegroundColor Gray
            git push origin $BranchName
            Write-Host "Successfully pushed code to GitHub!" -ForegroundColor Gray
        } else {
            Write-Host "No changes to commit. Skipping git commit/push." -ForegroundColor Yellow
        }

        # Handle GitHub Release creation via GitHub CLI (gh)
        $GhCmd = Get-Command "gh" -ErrorAction SilentlyContinue
        if ($GhCmd) {
            Write-Host "GitHub CLI (gh) detected. Creating/updating release 'v$AppVersion' on tamatasoft/flowpaisa..." -ForegroundColor Gray
            if (Test-Path $GeneratedSetupPath) {
                # Check if release already exists on tamatasoft/flowpaisa. If yes, delete it first to avoid conflicts, then create fresh.
                & gh release delete "v$AppVersion" --repo "tamatasoft/flowpaisa" --yes 2>$null
                
                # Create a release on tamatasoft/flowpaisa and upload the installer asset.
                & gh release create "v$AppVersion" $GeneratedSetupPath --repo "tamatasoft/flowpaisa" --title "v$AppVersion" --notes "Release v$AppVersion (Build $BuildNumber)"
                Write-Host "Successfully created GitHub Release on tamatasoft/flowpaisa and uploaded flowpaisa_setup.exe!" -ForegroundColor Green
            } else {
                Write-Host "WARNING: Could not upload release asset because '$GeneratedSetupPath' was not found." -ForegroundColor Yellow
            }
        } else {
            Write-Host "`n--------------------------------------------------" -ForegroundColor Yellow
            Write-Host "👉 TIP: Install GitHub CLI (gh) to fully automate uploading the installer!" -ForegroundColor Yellow
            Write-Host "You can install it right now by running this in PowerShell:" -ForegroundColor Yellow
            Write-Host "winget install --id GitHub.cli" -ForegroundColor Cyan
            Write-Host "Then run: gh auth login" -ForegroundColor Cyan
            Write-Host "Once logged in, this script will automatically upload the installer to GitHub Releases for you!" -ForegroundColor Yellow
            Write-Host "--------------------------------------------------`n" -ForegroundColor Yellow
        }
    } else {
        Write-Host "WARNING: Git command was not found in your system PATH. Skipping Git push step..." -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[4/5] Skipping Git push and GitHub Release creation." -ForegroundColor Yellow
}

# 6. Deploy to Firebase Hosting
Write-Host "`n[5/5] Deploying to Firebase Hosting..." -ForegroundColor Green

# Check if Firebase CLI is installed
$FirebaseCmd = Get-Command "firebase" -ErrorAction SilentlyContinue
if ($FirebaseCmd) {
    Write-Host "Deploying website files to Firebase Hosting..." -ForegroundColor Gray
    & firebase deploy --only hosting
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n🚀 DEPLOYMENT PIPELINE COMPLETE!" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Green
        Write-Host "   RELEASE & DEPLOYMENT DETAILS" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Green
        Write-Host "• App Version:             v$AppVersion" -ForegroundColor Gray
        Write-Host "• Build Number:            $BuildNumber" -ForegroundColor Gray
        Write-Host "• Landing Page Website:    https://flow-paisa.firebaseapp.com" -ForegroundColor Cyan
        Write-Host "• Auto-Update Config:      https://flow-paisa.firebaseapp.com/version.json" -ForegroundColor Cyan
        Write-Host "• GitHub Release Page:     https://github.com/tamatasoft/flowpaisa/releases/tag/v$AppVersion" -ForegroundColor Cyan
        Write-Host "• Public Download Link:    https://github.com/tamatasoft/flowpaisa/releases/download/v$AppVersion/$SetupOutputName" -ForegroundColor Cyan
        Write-Host "• Latest Download Link:    https://github.com/tamatasoft/flowpaisa/releases/latest/download/$SetupOutputName" -ForegroundColor Cyan
        Write-Host "==================================================" -ForegroundColor Green
        
        if (!$SkipRelease -and !(Get-Command "gh" -ErrorAction SilentlyContinue)) {
            Write-Host "`n⚠️  ACTION REQUIRED: GitHub CLI (gh) was not found." -ForegroundColor Yellow
            Write-Host "Please go to: https://github.com/tamatasoft/flowpaisa/releases" -ForegroundColor Yellow
            Write-Host "1. Create a release named 'v$AppVersion'" -ForegroundColor Yellow
            Write-Host "2. Upload the installer located at: .\Output\$SetupOutputName" -ForegroundColor Yellow
        } else {
            Write-Host "`n✨ All assets have been built, pushed, and deployed successfully!" -ForegroundColor Green
        }
    } else {
        Write-Error "Firebase deployment failed!"
        exit $LASTEXITCODE
    }
} else {
    Write-Host "WARNING: Firebase CLI (firebase) was not found in your system PATH." -ForegroundColor Yellow
    Write-Host "You can manually deploy by running: firebase deploy --only hosting" -ForegroundColor Yellow
}

Write-Host "`nPipeline completed!" -ForegroundColor Cyan
