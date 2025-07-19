@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Android Keystore Generator
echo ========================================
echo.

REM Check Java environment
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Java not found. Please install JDK and configure PATH.
    pause
    exit /b 1
)

REM Set paths using script directory
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "KEYSTORE_PATH=%PROJECT_ROOT%\android\app\lksms-release-key.jks"
set "KEY_ALIAS=lksms-key"
set "KEY_PROPERTIES_PATH=%PROJECT_ROOT%\android\key.properties"

echo Keystore file: !KEYSTORE_PATH!
echo Key alias: !KEY_ALIAS!
echo.

REM Check if keystore already exists
if exist "!KEYSTORE_PATH!" (
    echo Warning: Keystore file already exists!
    set /p "OVERWRITE=Overwrite existing keystore? (y/N): "
    if /i not "!OVERWRITE!"=="y" (
        echo Operation cancelled.
        pause
        exit /b 0
    )
    echo Deleting existing keystore...
    del "!KEYSTORE_PATH!"
)

echo.
echo Please enter keystore information when prompted...
echo Note: Please keep your passwords safe!
echo.

REM Generate keystore
keytool -genkey -v -keystore "!KEYSTORE_PATH!" -alias "!KEY_ALIAS!" -keyalg RSA -keysize 2048 -validity 10000 -storetype JKS

if %errorlevel% neq 0 (
    echo.
    echo Error: Keystore generation failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Keystore generated successfully!
echo ========================================
echo Keystore file: !KEYSTORE_PATH!
echo Key alias: !KEY_ALIAS!
echo.

REM Create key.properties template
echo Creating key.properties configuration file...
(
echo # Android signing configuration
echo # Please fill in the correct passwords
echo storePassword=YOUR_STORE_PASSWORD
echo keyPassword=YOUR_KEY_PASSWORD
echo keyAlias=!KEY_ALIAS!
echo storeFile=lksms-release-key.jks
) > "!KEY_PROPERTIES_PATH!"

echo.
echo key.properties file created: !KEY_PROPERTIES_PATH!
echo Please edit this file and fill in your passwords.
echo.

echo Next steps:
echo 1. Edit android\key.properties file with your passwords
echo 2. Run scripts\build_release.bat for production build
echo.
pause
