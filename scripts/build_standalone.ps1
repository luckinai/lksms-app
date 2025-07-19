param(
    [string]$Version = "1.0.0"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Standalone APK Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory and project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host "Target: Standalone APK (Non-Google Play)" -ForegroundColor Cyan
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
Write-Host "Step 3: Cleaning project..." -ForegroundColor Yellow
flutter clean
Write-Host "Clean completed." -ForegroundColor Green
Write-Host ""

# Get dependencies
Write-Host "Step 4: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "Dependencies completed." -ForegroundColor Green
Write-Host ""

# Build APK for standalone distribution
Write-Host "Step 5: Building standalone APK..." -ForegroundColor Yellow
Write-Host "Building APK optimized for standalone distribution..." -ForegroundColor Cyan
Write-Host "This may take several minutes, please wait..." -ForegroundColor Cyan

# Build with specific flags for standalone APK
flutter build apk --release --build-name=$Version --split-per-abi

$buildSuccess = $LASTEXITCODE -eq 0
Write-Host ""

if ($buildSuccess) {
    Write-Host "Build completed successfully." -ForegroundColor Green
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Trying fallback build without split-per-abi..." -ForegroundColor Yellow
    flutter build apk --release --build-name=$Version
    $buildSuccess = $LASTEXITCODE -eq 0
}
Write-Host ""

# Check result and organize files
Write-Host "Step 6: Organizing build results..." -ForegroundColor Yellow

# Create release directory
$ReleaseDir = "build\release"
if (!(Test-Path $ReleaseDir)) {
    New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
}

$ApkFound = $false

# Check for split APKs first
$SplitApkDir = "build\app\outputs\flutter-apk"
if (Test-Path $SplitApkDir) {
    $ApkFiles = Get-ChildItem "$SplitApkDir\*.apk" -ErrorAction SilentlyContinue
    
    if ($ApkFiles) {
        Write-Host "[SUCCESS] APK files created:" -ForegroundColor Green
        
        foreach ($apk in $ApkFiles) {
            $FileSize = $apk.Length
            $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
            Write-Host "  $($apk.Name): $FileSizeMB MB" -ForegroundColor Green
            
            # Copy to release directory with version
            $VersionedName = $apk.Name -replace "app-", "lksms-v$Version-"
            Copy-Item $apk.FullName "$ReleaseDir\$VersionedName" -Force
            Write-Host "  Copied to: $ReleaseDir\$VersionedName" -ForegroundColor Cyan
        }
        
        # Copy the universal APK or the largest one to root for quick access
        $UniversalApk = $ApkFiles | Where-Object { $_.Name -match "universal" } | Select-Object -First 1
        if (!$UniversalApk) {
            $UniversalApk = $ApkFiles | Sort-Object Length -Descending | Select-Object -First 1
        }
        
        if ($UniversalApk) {
            Copy-Item $UniversalApk.FullName "lksms-standalone.apk" -Force
            Write-Host "  Quick access copy: lksms-standalone.apk" -ForegroundColor Green
        }
        
        $ApkFound = $true
    }
}

# Check for single APK if no split APKs found
if (!$ApkFound) {
    $SingleApkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $SingleApkPath) {
        Write-Host "[SUCCESS] Single APK created:" -ForegroundColor Green
        
        $FileSize = (Get-Item $SingleApkPath).Length
        $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
        Write-Host "  app-release.apk: $FileSizeMB MB" -ForegroundColor Green
        
        # Copy to release directory with version
        $VersionedApk = "$ReleaseDir\lksms-v$Version-standalone.apk"
        Copy-Item $SingleApkPath $VersionedApk -Force
        Write-Host "  Copied to: $VersionedApk" -ForegroundColor Cyan
        
        # Copy to root for quick access
        Copy-Item $SingleApkPath "lksms-standalone.apk" -Force
        Write-Host "  Quick access copy: lksms-standalone.apk" -ForegroundColor Green
        
        $ApkFound = $true
    }
}

if (!$ApkFound) {
    Write-Host "[ERROR] No APK files found!" -ForegroundColor Red
    Write-Host "Expected locations:" -ForegroundColor Red
    Write-Host "  - build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Red
    Write-Host "  - build\app\outputs\flutter-apk\app-*-release.apk" -ForegroundColor Red
}
Write-Host ""

# Create build info
if ($ApkFound) {
    Write-Host "Creating build information..." -ForegroundColor Yellow
    $BuildInfo = "$ReleaseDir\build-info-v$Version-standalone.txt"
    
    $ApkList = Get-ChildItem "$ReleaseDir\lksms-v$Version-*.apk" -ErrorAction SilentlyContinue
    
    @"
LKSMS Standalone Build Information
==================================
Version: $Version
Build date: $(Get-Date -Format "yyyy-MM-dd")
Build time: $(Get-Date -Format "HH:mm:ss")
Build type: Standalone APK (Non-Google Play)

Flutter version:
$(flutter --version)

Build configuration:
- Code obfuscation: Disabled
- Resource shrinking: Disabled
- Target: Standalone distribution
- Signing: Release keystore

Build artifacts:
$(if ($ApkList) { $ApkList | ForEach-Object { "- $($_.Name) ($([math]::Round($_.Length / 1MB, 2)) MB)" } } else { "- No APK files found" })

Installation notes:
1. Enable "Unknown sources" in Android settings
2. Install APK directly on device
3. Grant necessary permissions when prompted

Architecture support:
$(if (Get-ChildItem "$ReleaseDir\*arm64*" -ErrorAction SilentlyContinue) { "- ARM64 (64-bit, recommended for modern devices)" })
$(if (Get-ChildItem "$ReleaseDir\*armeabi-v7a*" -ErrorAction SilentlyContinue) { "- ARMv7 (32-bit, compatible with older devices)" })
$(if (Get-ChildItem "$ReleaseDir\*x86_64*" -ErrorAction SilentlyContinue) { "- x86_64 (64-bit Intel/AMD)" })
$(if (Get-ChildItem "$ReleaseDir\*universal*" -ErrorAction SilentlyContinue) { "- Universal (all architectures, larger size)" })
"@ | Out-File -FilePath $BuildInfo -Encoding UTF8
    
    Write-Host "Build info saved to: $BuildInfo" -ForegroundColor Green
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Standalone Build Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host "Build Type: Standalone APK" -ForegroundColor Green
Write-Host "Target: Direct installation (Non-Google Play)" -ForegroundColor Green

if ($ApkFound) {
    Write-Host "Status: SUCCESS - APK ready for distribution" -ForegroundColor Green
    if (Test-Path "lksms-standalone.apk") {
        Write-Host "Quick access: lksms-standalone.apk" -ForegroundColor Green
    }
    Write-Host "Release directory: $ReleaseDir" -ForegroundColor Green
} else {
    Write-Host "Status: FAILED - APK not created" -ForegroundColor Red
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Test the APK on your Android device" -ForegroundColor White
Write-Host "2. Enable 'Unknown sources' in Android settings" -ForegroundColor White
Write-Host "3. Install APK directly on device" -ForegroundColor White
Write-Host "4. Distribute APK file to users" -ForegroundColor White
Write-Host ""

# Ask to open release directory
if ($ApkFound) {
    $OpenDir = Read-Host "Open release directory? (Y/n)"
    if ($OpenDir -ne "n" -and $OpenDir -ne "N") {
        explorer $ReleaseDir
    }
}

Write-Host "Standalone build completed." -ForegroundColor Green
