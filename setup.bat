@echo off
setlocal
title USEYI Monitor - Setup

echo ==========================================
echo       USEYI Monitor Setup
echo ==========================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
    echo ERROR: Flutter was not found in PATH.
    echo.
    echo Install Flutter first, add its "bin" folder to PATH,
    echo then close and reopen VS Code.
    echo.
    pause
    exit /b 1
)

echo Flutter found:
flutter --version
echo.

echo Creating Android and iOS project folders...
flutter create --platforms=android,ios .
if errorlevel 1 (
    echo.
    echo ERROR: Flutter project creation failed.
    pause
    exit /b 1
)

echo.
echo Installing USEYI Monitor packages...
flutter pub get
if errorlevel 1 (
    echo.
    echo ERROR: Package installation failed.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Setup completed successfully!
echo ==========================================
echo.
echo To test on an Android phone:
echo   flutter devices
echo   flutter run
echo.
echo For iOS:
echo   Copy/open this project on a Mac with Xcode.
echo.
pause
