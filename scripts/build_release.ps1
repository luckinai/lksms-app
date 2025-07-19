param(
    [string]$Version = "1.0.0"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PowerShell Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory and project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host ""

# Check Flutter
Write-Host "Step 1: Checking Flutter..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Check required files
Write-Host "Step 2: Checking required files..." -ForegroundColor Yellow
if (Test-Path "pubspec.yaml") {
    Write-Host "[OK] pubspec.yaml found" -ForegroundColor Green
} else {
    Write-Host "[WARNING] pubspec.yaml not found" -ForegroundColor Red
}

if (Test-Path "android\key.properties") {
    Write-Host "[OK] android\key.properties found" -ForegroundColor Green
} else {
    Write-Host "[WARNING] android\key.properties not found" -ForegroundColor Red
}

if (Test-Path "android\app\lksms-release-key.jks") {
    Write-Host "[OK] keystore file found" -ForegroundColor Green
} else {
    Write-Host "[WARNING] keystore file not found" -ForegroundColor Red
}
Write-Host ""

# Clean project
# Write-Host "Step 3: Cleaning project..." -ForegroundColor Yellow
# flutter clean
# Write-Host "Clean completed." -ForegroundColor Green
# Write-Host ""

# # Get dependencies
# Write-Host "Step 4: Getting dependencies..." -ForegroundColor Yellow
# flutter pub get
# Write-Host "Dependencies completed." -ForegroundColor Green
# Write-Host ""

# Build APK
Write-Host "Step 3: Building APK..." -ForegroundColor Yellow
Write-Host "This may take several minutes, please wait..." -ForegroundColor Cyan
flutter build apk --release --build-name=$Version
Write-Host "Build completed." -ForegroundColor Green
Write-Host ""

# Check result
Write-Host "Step 4: Checking build result..." -ForegroundColor Yellow
$ApkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $ApkPath) {
    Write-Host "[SUCCESS] APK created successfully!" -ForegroundColor Green
    Write-Host "Location: $ApkPath" -ForegroundColor Green
    
    # Get file size
    $FileSize = (Get-Item $ApkPath).Length
    $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
    Write-Host "Size: $FileSize bytes ($FileSizeMB MB)" -ForegroundColor Green
    
    # Copy to root directory
    Copy-Item $ApkPath "lksms-release.apk" -Force
    Write-Host "Copied to: lksms-release.apk" -ForegroundColor Green
    
    # Create release directory and copy with version name
    $ReleaseDir = "build\release"
    if (!(Test-Path $ReleaseDir)) {
        New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
    }
    
    $VersionedApk = "$ReleaseDir\lksms-v$Version-release.apk"
    Copy-Item $ApkPath $VersionedApk -Force
    Write-Host "Versioned copy: $VersionedApk" -ForegroundColor Green
    
} else {
    Write-Host "[ERROR] APK not found!" -ForegroundColor Red
    Write-Host "Expected location: $ApkPath" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Green
if (Test-Path "lksms-release.apk") {
    Write-Host "Status: SUCCESS - APK ready for testing" -ForegroundColor Green
    Write-Host "Quick access: lksms-release.apk" -ForegroundColor Green
} else {
    Write-Host "Status: FAILED - APK not created" -ForegroundColor Red
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Test the APK on your Android device" -ForegroundColor White
Write-Host "2. Enable 'Unknown sources' in Android settings for direct installation" -ForegroundColor White
Write-Host "3. For optimized standalone APK, use: .\scripts\build_standalone.ps1" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue"
