@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul 2>&1

echo ========================================
echo   Android Voice to Windows Clipboard
echo   WiFi Wireless Mode - Auto Start
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
    echo [WARN] Could not detect IP. Please check manually with 'ipconfig'
    set "LOCAL_IP=unknown"
)
echo.

REM --- Check Firewall ---
echo [2/3] Checking firewall settings...
echo Note: Make sure port 8889 is allowed through Windows Firewall
echo To add firewall rule, run as Administrator:
echo   netsh advfirewall firewall add rule name="ClipSync" dir=in action=allow protocol=TCP localport=8889
echo.

REM --- Start Apps ---
echo [3/3] Starting applications...
echo.
echo Tips:
echo    - Windows will run as WebSocket server on port 8889
echo    - In Android app, tap Settings (gear icon) to configure PC IP
echo    - Enter the IP shown above: %LOCAL_IP%
echo    - Make sure both devices are on the same WiFi network
echo.
echo Press any key to start the apps...
pause >nul

echo.
echo Starting Windows server...
start "WinServer" cmd /c "flutter run -d windows"

echo Waiting 5 seconds for Windows to initialize...
ping 127.0.0.1 -n 6 >nul

echo.
echo Starting Android client...
start "AndroidClient" cmd /c "flutter run -d android"

echo.
echo ========================================
echo   Applications launched in new windows!
echo   Close the console windows to stop.
echo ========================================
exit /b 0
