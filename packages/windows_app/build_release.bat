@echo off
chcp 65001 >nul
echo ========================================
echo   Windows 应用构建和发布脚本
echo ========================================
echo.

REM 清理旧的构建产物
echo [1/4] 清理旧的构建产物...
call flutter clean
if %errorlevel% neq 0 (
    echo ⚠️ 清理警告（可忽略）
)
echo.

REM 获取依赖
echo [2/4] 获取依赖...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ 依赖获取失败
    pause
    exit /b 1
)
echo.

REM 构建 Windows 应用
echo [3/4] 构建 Windows 应用...
echo 💡 提示：首次构建可能需要几分钟时间...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo ❌ Windows 应用构建失败
    echo 💡 提示：需要安装 Visual Studio C++ 桌面开发工作负载
    pause
    exit /b 1
)
echo.

REM 复制文件到 release/windows 目录
echo [4/4] 复制文件到 release/windows 目录...
if not exist "release\windows" mkdir "release\windows"
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "release\windows\" >nul
if %errorlevel% neq 0 (
    echo ❌ 复制失败
    pause
    exit /b 1
)

echo.
echo ✅ 构建完成！
echo 📦 EXE 位置: release\windows\clip_sync_wifi.exe
echo 📌 提示：现在支持托盘功能，点击关闭按钮会隐藏到托盘
echo.
pause
