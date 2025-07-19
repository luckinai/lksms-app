param(
    [string]$Version = "1.0.0"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Debug Verbose Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory and project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host ""

# Check Java configuration
Write-Host "Step 1: Checking Java configuration..." -ForegroundColor Yellow
Write-Host "System Java version:" -ForegroundColor Cyan
java -version
Write-Host ""

Write-Host "JAVA_HOME environment variable:" -ForegroundColor Cyan
if ($env:JAVA_HOME) {
    Write-Host $env:JAVA_HOME -ForegroundColor Green
} else {
    Write-Host "Not set" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Gradle Java configuration:" -ForegroundColor Cyan
if (Test-Path "android\gradle.properties") {
    $gradleProps = Get-Content "android\gradle.properties"
    $javaHome = $gradleProps | Where-Object { $_ -match "org.gradle.java.home" }
    if ($javaHome) {
        Write-Host $javaHome -ForegroundColor Green
    } else {
        Write-Host "Not configured in gradle.properties" -ForegroundColor Yellow
    }
} else {
    Write-Host "gradle.properties not found" -ForegroundColor Red
}
Write-Host ""

# Check Flutter
Write-Host "Step 2: Checking Flutter..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Check Android configuration
Write-Host "Step 3: Checking Android configuration..." -ForegroundColor Yellow
Write-Host "app/build.gradle Java version:" -ForegroundColor Cyan
if (Test-Path "android\app\build.gradle") {
    $buildGradle = Get-Content "android\app\build.gradle"
    $javaVersion = $buildGradle | Where-Object { $_ -match "JavaVersion" }
    $kotlinOptions = $buildGradle | Where-Object { $_ -match "jvmTarget" }
    
    if ($javaVersion) {
        $javaVersion | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    }
    if ($kotlinOptions) {
        $kotlinOptions | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    }
} else {
    Write-Host "build.gradle not found" -ForegroundColor Red
}
Write-Host ""

Write-Host "settings.gradle Kotlin version:" -ForegroundColor Cyan
if (Test-Path "android\settings.gradle") {
    $settingsGradle = Get-Content "android\settings.gradle"
    $kotlinVersion = $settingsGradle | Where-Object { $_ -match "kotlin.android" }
    if ($kotlinVersion) {
        $kotlinVersion | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    }
} else {
    Write-Host "settings.gradle not found" -ForegroundColor Red
}
Write-Host ""

# Check required files
Write-Host "Step 4: Checking required files..." -ForegroundColor Yellow
$files = @(
    "pubspec.yaml",
    "android\key.properties", 
    "android\app\lksms-release-key.jks"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "[OK] $file found" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] $file not found" -ForegroundColor Red
    }
}
Write-Host ""

# Clean project
Write-Host "Step 5: Cleaning project..." -ForegroundColor Yellow
flutter clean
Write-Host "Clean completed." -ForegroundColor Green
Write-Host ""

# Get dependencies
Write-Host "Step 6: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "Dependencies completed." -ForegroundColor Green
Write-Host ""

# Build APK with verbose output
Write-Host "Step 7: Building APK (verbose)..." -ForegroundColor Yellow
Write-Host "This may take several minutes, please wait..." -ForegroundColor Cyan
flutter build apk --release --build-name=$Version --verbose

$buildSuccess = $LASTEXITCODE -eq 0
Write-Host ""

if ($buildSuccess) {
    Write-Host "Build completed successfully." -ForegroundColor Green
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
}
Write-Host ""

# Check result
Write-Host "Step 8: Checking build result..." -ForegroundColor Yellow
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
    
} else {
    Write-Host "[ERROR] APK not found!" -ForegroundColor Red
    Write-Host "Expected location: $ApkPath" -ForegroundColor Red
    
    # Show build directory structure
    Write-Host "Build directory structure:" -ForegroundColor Cyan
    if (Test-Path "build") {
        Get-ChildItem "build" -Recurse -Name | Select-Object -First 20 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor White
        }
    } else {
        Write-Host "  build directory not found" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Debug Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build Success: $buildSuccess" -ForegroundColor $(if ($buildSuccess) { "Green" } else { "Red" })
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to continue"
