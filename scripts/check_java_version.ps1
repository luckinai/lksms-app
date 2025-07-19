Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Java Version Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Java version
Write-Host "Checking Java version..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1
    Write-Host $javaVersion -ForegroundColor Green
    
    # Extract version number
    $versionLine = $javaVersion | Select-String "version"
    if ($versionLine) {
        Write-Host ""
        if ($versionLine -match '"1\.8\.') {
            Write-Host "[INFO] Java 8 detected" -ForegroundColor Yellow
            Write-Host "Recommendation: Consider upgrading to Java 17 for better compatibility" -ForegroundColor Yellow
        } elseif ($versionLine -match '"17\.') {
            Write-Host "[OK] Java 17 detected - Perfect for current project configuration" -ForegroundColor Green
        } elseif ($versionLine -match '"11\.') {
            Write-Host "[OK] Java 11 detected - Compatible but Java 17 is recommended" -ForegroundColor Green
        } else {
            Write-Host "[INFO] Other Java version detected" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "[ERROR] Java not found or not in PATH" -ForegroundColor Red
    Write-Host "Please install Java and add it to your PATH" -ForegroundColor Red
}

Write-Host ""

# Check JAVA_HOME
Write-Host "Checking JAVA_HOME..." -ForegroundColor Yellow
if ($env:JAVA_HOME) {
    Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
} else {
    Write-Host "[WARNING] JAVA_HOME not set" -ForegroundColor Yellow
    Write-Host "Consider setting JAVA_HOME environment variable" -ForegroundColor Yellow
}

Write-Host ""

# Check Flutter doctor
Write-Host "Checking Flutter doctor..." -ForegroundColor Yellow
flutter doctor --android-licenses

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Current Project Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Java compile target: VERSION_17" -ForegroundColor Green
Write-Host "Kotlin JVM target: 17" -ForegroundColor Green
Write-Host "Kotlin version: 1.9.0" -ForegroundColor Green
Write-Host ""

Write-Host "If you encounter build issues:" -ForegroundColor Cyan
Write-Host "1. Ensure you have Java 17 installed" -ForegroundColor White
Write-Host "2. Set JAVA_HOME to Java 17 installation" -ForegroundColor White
Write-Host "3. Run 'flutter clean' and try building again" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue"
