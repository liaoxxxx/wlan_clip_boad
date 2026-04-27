@echo off
chcp 65001 >nul
echo ========================================
echo   窗口自适应功能测试
echo ========================================
echo.

echo 📝 测试步骤：
echo.
echo 1. 启动应用后，尝试以下操作：
echo.
echo    a) 完整模式 (高度 ≥ 450px)
echo       - 确认所有组件都显示
echo       - 包括：标题栏、状态卡片、文本区、
echo         输入模式、悬浮窗设置、提示、日志
echo.
echo    b) 紧凑模式 (300px ≤ 高度 ^< 450px)
echo       - 向下拖动窗口底部
echo       - 确认以下组件隐藏：
echo         * IP 地址详情
echo         * 粘贴方式选项
echo         * 悬浮窗设置
echo         * 使用说明
echo         * 日志区域
echo.
echo    c) 最小模式 (高度 ^< 300px)
echo       - 继续缩小窗口
echo       - 确认只显示文本区域
echo       - 标题栏消失
echo       - 文本标题简化为 "📝"
echo.
echo 2. 测试最小限制
echo    - 尝试将窗口缩到最小
echo    - 确认不能小于 200px 高度
echo    - 确认文本依然清晰可读
echo.
echo ========================================
echo.
echo 按任意键启动应用...
pause >nul
echo.

flutter run -d windows
