@echo off
setlocal enabledelayedexpansion

REM Set code page to UTF-8 for better character support
chcp 65001 >nul 2>&1

echo ========================================
echo   Clip Sync USB - App Installer
echo   Install Windows ^& Android Apps
echo ========================================
echo.

REM --- Step 1: Find ADB ---
set "ADB_FOUND=0"
set "ADB_PATH="

REM Check if adb is in PATH
where adb >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%i in ('where adb') do (
        set "ADB_EXE_FROM_PATH=%%i"
        goto :adb_found_from_where
    )
    :adb_found_from_where
    for %%i in ("%ADB_EXE_FROM_PATH%") do set "ADB_PATH=%%~dpi"
    set "ADB_FOUND=1"
    goto :adb_ready
)

REM Try Flutter SDK's ADB
if defined FLUTTER_ROOT (
    set "POTENTIAL_ADB=%FLUTTER_ROOT%\bin\cache\artifacts\android-platform\adb.exe"
    if exist "!POTENTIAL_ADB!" (
        set "ADB_PATH=%FLUTTER_ROOT%\bin\cache\artifacts\android-platform"
        set "ADB_FOUND=1"
        goto :adb_ready
    )
    REM Fallback for some Flutter structures
    set "POTENTIAL_ADB2=%FLUTTER_ROOT%\bin\cache\dart-sdk\bin\..\..\..\platform-tools\adb.exe"
    if exist "!POTENTIAL_ADB2!" (
        for %%i in ("!POTENTIAL_ADB2!") do set "ADB_PATH=%%~dpi"
        set "ADB_FOUND=1"
        goto :adb_ready
    )
)

REM Check common Android SDK locations
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set "ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools"
    set "ADB_FOUND=1"
    goto :adb_ready
)

if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
    set "ADB_PATH=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools"
    set "ADB_FOUND=1"
    goto :adb_ready
)

if exist "C:\Android\platform-tools\adb.exe" (
    set "ADB_PATH=C:\Android\platform-tools"
    set "ADB_FOUND=1"
    goto :adb_ready
)

:adb_ready
if "%ADB_FOUND%"=="1" (
    if defined ADB_PATH (
        set "PATH=%ADB_PATH%;%PATH%"
        echo [OK] Using ADB from: %ADB_PATH%
    ) else (
        echo [OK] Using ADB from system PATH
    )
) else (
    echo [ERROR] ADB not found!
    echo.
    echo Please install Android SDK Platform-Tools:
    echo https://developer.android.com/studio/releases/platform-tools
    echo.
    pause
    exit /b 1
)
echo.

REM --- Step 2: Check Flutter ---
echo [1/4] Checking Flutter environment...
where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found in PATH!
    echo Please install Flutter SDK and add it to your PATH.
    echo https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo [OK] Flutter found
flutter --version
echo.

REM --- Step 3: Get Dependencies ---
echo [2/4] Getting Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM --- Step 4: Build and Install Android App ---
echo [3/4] Building and installing Android app...
echo This may take a few minutes on first build...
call flutter build apk --release
if errorlevel 1 (
    echo [ERROR] Failed to build Android APK
    pause
    exit /b 1
)
echo [OK] Android APK built successfully

set "ANDROID_STATUS=Not installed"

REM Check if device is connected
"%ADB_PATH%\adb.exe" devices | findstr "device$" >nul 2>&1
if errorlevel 1 (
    echo [WARNING] No Android device detected
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
    echo Please connect a device or manually install the APK
    set "ANDROID_STATUS=Built (no device connected)"
    echo.
) else (
    echo Installing APK to connected device...
    "%ADB_PATH%\adb.exe" install -r "build\app\outputs\flutter-apk\app-release.apk"
    if errorlevel 1 (
        echo [ERROR] Failed to install APK
        echo You can manually install from: build\app\outputs\flutter-apk\app-release.apk
        set "ANDROID_STATUS=Build failed during install"
    ) else (
        echo [OK] Android app installed successfully
        set "ANDROID_STATUS=Installed on device"
    )
)
echo.

REM --- Step 5: Build Windows App ---
echo [4/4] Building Windows app...
echo This may take a few minutes on first build...
call flutter build windows --release
if errorlevel 1 (
    echo [ERROR] Failed to build Windows app
    echo.
    echo Note: Windows desktop support must be enabled in Flutter
    echo Run: flutter config --enable-windows-desktop
    pause
    exit /b 1
)
echo [OK] Windows app built successfully
echo Location: build\windows\x64\runner\Release\
echo.

REM --- Summary ---
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Android App:
echo   - APK: build\app\outputs\flutter-apk\app-release.apk
echo   - Status: %ANDROID_STATUS%
echo.
echo Windows App:
echo   - Location: build\windows\x64\runner\Release\
echo   - Executable: clip_sync_usb.exe
echo.
echo To run the apps:
echo   1. Double-click start_sync.bat for automatic startup
echo   2. Or manually run both apps from their build directories
echo.
echo ========================================
pause
exit /b 0
