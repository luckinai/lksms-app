@echo off

echo ========================================
echo Quick Build Script (Testing)
echo ========================================
echo.

REM Go to project root
cd /d "%~dp0.."
echo Working directory: %CD%
echo.

echo [1/3] Cleaning project...
flutter clean

echo [2/3] Getting dependencies...
flutter pub get

echo [3/3] Building APK...
flutter build apk --release

echo.
echo Build completed!
echo APK location: build\app\outputs\flutter-apk\app-release.apk

REM Copy to root directory for easy access
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "lksms-debug.apk"
    echo Copied to: lksms-debug.apk
    echo.
    echo [SUCCESS] Quick build completed successfully!
) else (
    echo [ERROR] APK file not found
)

pause
