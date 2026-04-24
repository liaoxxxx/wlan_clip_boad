@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Clip Sync WiFi - Auto Start
echo ========================================
echo.

REM --- Get Local IP ---
echo [1/3] Getting local IP address...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set "LOCAL_IP=%%b"
        goto :ip_found
    )
)
:ip_found
if defined LOCAL_IP (
    echo [OK] Local IP: %LOCAL_IP%
) else (
    echo [WARN] Could not detect IP. Run 'ipconfig' manually.
    set "LOCAL_IP=unknown"
)
echo.

REM --- Firewall Info ---
echo [2/3] Firewall settings...
echo Note: Ensure port 8889 is allowed in Windows Firewall
echo Admin command to add rule:
echo   netsh advfirewall firewall add rule name="ClipSync" dir=in action=allow protocol=TCP localport=8889
echo.

REM --- Start App ---
echo [3/3] Starting Windows server...
echo.
echo Usage:
echo   - Windows runs as WebSocket server on port 8889
echo   - Android app: Settings -^> Enter PC IP: %LOCAL_IP%
echo   - Both devices must be on same WiFi network
echo.
echo Press any key to start...
pause >nul

echo.
echo Starting Clip Sync WiFi server...
start "ClipSync-Windows" cmd /k "cd /d %~dp0 && flutter run -d windows"

echo.
echo ========================================
echo   Windows server started in new window!
echo   Install Android APK manually:
echo     release\android\clip_sync_android.apk
echo   Command:
echo     adb install release\android\clip_sync_android.apk
echo ========================================
echo.
exit /b 0
