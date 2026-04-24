@echo off
chcp 65001 >nul
echo ========================================
echo   Windows 应用构建和发布脚本
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

REM 构建 Windows 应用
echo [3/4] 构建 Windows 应用...
flutter build windows --release
if %errorlevel% neq 0 (
    echo ❌ Windows 应用构建失败
    echo 💡 提示：需要安装 Visual Studio C++ 桌面开发工作负载
    exit /b 1
)

REM 复制文件到 release/windows 目录
echo [4/4] 复制文件到 release/windows 目录...
if not exist "release\windows" mkdir "release\windows"
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "release\windows\" >nul
if %errorlevel% neq 0 (
    echo ❌ 复制失败
    exit /b 1
)

echo.
echo ✅ 构建完成！
echo 📦 EXE 位置: release\windows\clip_sync_usb.exe
echo.
pause
