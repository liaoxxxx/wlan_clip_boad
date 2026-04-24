@echo off
chcp 65001 >nul
echo ========================================
echo   Android 应用构建和发布脚本
echo ========================================
echo.

REM 清理旧的构建产物
echo [1/4] 清理旧的构建产物...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ 清理失败
    exit /b 1
)

REM 获取依赖
echo [2/4] 获取依赖...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 依赖获取失败
    exit /b 1
)

REM 构建 APK
echo [3/4] 构建 APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ APK 构建失败
    exit /b 1
)

REM 复制 APK 到 release/android 目录
echo [4/4] 复制 APK 到 release/android 目录...
if not exist "release\android" mkdir "release\android"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "release\android\clip_sync_android.apk"
if %errorlevel% neq 0 (
    echo ❌ 复制失败
    exit /b 1
)

echo.
echo ✅ 构建完成！
echo 📦 APK 位置: release\android\clip_sync_android.apk
echo.
pause
