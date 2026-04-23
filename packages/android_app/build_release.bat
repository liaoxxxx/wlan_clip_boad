@echo off
setlocal enabledelayedexpansion

REM Set code page to UTF-8
chcp 65001 >nul 2>&1

echo ========================================
echo   Clip Sync USB - Release Builder
echo   Build Windows ^& Android Apps
echo ========================================
echo.

REM --- Check Flutter ---
echo [1/3] Checking Flutter environment...
where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found in PATH!
    pause
    exit /b 1
)
echo [OK] Flutter found
echo.

REM --- Get Dependencies ---
echo [2/3] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM --- Create output directory ---
set "OUTPUT_DIR=release"
set "WINDOWS_BUILT=0"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM --- Build Android APK ---
echo [3/3] Building Android APK (release mode)...
call flutter build apk --release
if errorlevel 1 (
    echo [ERROR] Failed to build Android APK
    pause
    exit /b 1
)

REM Copy APK to release directory
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "%OUTPUT_DIR%\clip_sync_android.apk" >nul
echo [OK] Android APK built: %OUTPUT_DIR%\clip_sync_android.apk
echo.

REM --- Build Windows App ---
echo Building Windows app (release mode)...
call flutter build windows --release
if errorlevel 1 (
    echo [WARNING] Failed to build Windows app
    echo Note: Visual Studio with C++ desktop workload is required
    echo Run 'flutter doctor' for more details
    echo Skipping Windows build, continuing with Android only...
    set "WINDOWS_BUILT=0"
) else (
    REM Copy Windows executable to release directory
    if not exist "%OUTPUT_DIR%\windows" mkdir "%OUTPUT_DIR%\windows"
    xcopy /E /I /Y "build\windows\x64\runner\Release\*" "%OUTPUT_DIR%\windows\" >nul
    echo [OK] Windows app built: %OUTPUT_DIR%\windows\
    set "WINDOWS_BUILT=1"
)
echo.

REM --- Create version info file ---
echo Clip Sync USB - Release Package > "%OUTPUT_DIR%\VERSION.txt"
echo Build Date: %date% %time% >> "%OUTPUT_DIR%\VERSION.txt"
echo. >> "%OUTPUT_DIR%\VERSION.txt"
echo Contents: >> "%OUTPUT_DIR%\VERSION.txt"
echo   - clip_sync_android.apk (Android app) >> "%OUTPUT_DIR%\VERSION.txt"
if "%WINDOWS_BUILT%"=="1" (
    echo   - windows/ (Windows app folder) >> "%OUTPUT_DIR%\VERSION.txt"
) else (
    echo   - windows/ (NOT BUILT - requires Visual Studio) >> "%OUTPUT_DIR%\VERSION.txt"
)
echo   - start_sync.bat (Quick start script) >> "%OUTPUT_DIR%\VERSION.txt"
echo. >> "%OUTPUT_DIR%\VERSION.txt"
echo Usage: >> "%OUTPUT_DIR%\VERSION.txt"
echo   Android: Install clip_sync_android.apk on your phone >> "%OUTPUT_DIR%\VERSION.txt"
if "%WINDOWS_BUILT%"=="1" (
    echo   Windows: Run windows\clip_sync_usb.exe >> "%OUTPUT_DIR%\VERSION.txt"
) else (
    echo   Windows: Build manually with 'flutter build windows --release' >> "%OUTPUT_DIR%\VERSION.txt"
)
echo   Then run: adb forward tcp:8889 tcp:8889 >> "%OUTPUT_DIR%\VERSION.txt"

REM --- Copy start script ---
copy /Y "start_sync.bat" "%OUTPUT_DIR%\start_sync.bat" >nul

REM --- Summary ---
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Release package created in: %OUTPUT_DIR%\
echo.
echo Contents:
dir /B "%OUTPUT_DIR%"
echo.
echo Next steps:
echo   1. Distribute the '%OUTPUT_DIR%' folder
echo   2. Users should install Android APK on their phone
echo   3. Users should run windows\clip_sync_usb.exe on PC
echo   4. Connect phone via USB and run: adb forward tcp:8889 tcp:8889
echo.
echo ========================================
pause
exit /b 0
