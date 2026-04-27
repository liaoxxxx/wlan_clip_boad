@echo off
chcp 65001 >nul
echo ========================================
echo   Windows 托盘功能测试指南
echo ========================================
echo.

echo [步骤 1] 清理并获取依赖
echo ----------------------------------------
call flutter clean
call flutter pub get
echo.

echo [步骤 2] 编译 Windows 版本
echo ----------------------------------------
echo 提示：这将编译应用，可能需要几分钟...
echo.
call flutter build windows --release
echo.

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 编译失败！请检查错误信息。
    pause
    exit /b 1
)

echo ✅ 编译成功！
echo.

echo [步骤 3] 运行应用进行测试
echo ----------------------------------------
echo 提示：按 Ctrl+C 可以停止应用
echo.
echo 测试项目：
echo   1. 点击关闭按钮 → 应隐藏到托盘
echo   2. 左键点击托盘图标 → 应显示窗口
echo   3. 右键点击托盘图标 → 应弹出菜单
echo   4. 选择"退出" → 应完全退出应用
echo.
echo 按任意键启动应用...
pause >nul
echo.

call flutter run -d windows

echo.
echo ========================================
echo   测试完成
echo ========================================
pause
