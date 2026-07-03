# deploy_windows.ps1
# Flowpaisa Windows Build, Package & Deploy Automation Script
# This script automates compiling, packaging with Inno Setup, committing/pushing to GitHub, creating a GitHub Release with the installer asset, and deploying to Firebase Hosting.

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

# 3. Package the Installer using Inno Setup
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

# 4. Copy Installer to Website Directory
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

# 5. Git Commit & Push to GitHub + Create GitHub Release
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
        Write-Host "GitHub CLI (gh) detected. Creating/updating release 'v$AppVersion' on GitHub..." -ForegroundColor Gray
        if (Test-Path $GeneratedSetupPath) {
            # Create a release and upload the installer asset. --clobber overwrites existing assets if they exist.
            & gh release create "v$AppVersion" $GeneratedSetupPath --title "v$AppVersion" --notes "Release v$AppVersion (Build $BuildNumber)" --clobber
            Write-Host "Successfully created GitHub Release and uploaded flowpaisa_setup.exe!" -ForegroundColor Green
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

# 6. Deploy to Firebase Hosting
Write-Host "`n[5/5] Deploying to Firebase Hosting..." -ForegroundColor Green

# Check if Firebase CLI is installed
$FirebaseCmd = Get-Command "firebase" -ErrorAction SilentlyContinue
if ($FirebaseCmd) {
    Write-Host "Deploying website files to Firebase Hosting..." -ForegroundColor Gray
    & firebase deploy --only hosting
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n🚀 DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
        Write-Host "Your Windows app update is now live on Firebase Hosting!" -ForegroundColor Green
        Write-Host "Website: https://flow-paisa.firebaseapp.com" -ForegroundColor Cyan
        Write-Host "Update Config: https://flow-paisa.firebaseapp.com/version.json" -ForegroundColor Cyan
        
        if (!(Get-Command "gh" -ErrorAction SilentlyContinue)) {
            Write-Host "`nNext Step: Go to GitHub (https://github.com/tamatasoft/flowpaisa/releases), create a release named 'v$AppVersion', and upload the generated installer located at: .\Output\$SetupOutputName" -ForegroundColor Yellow
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
