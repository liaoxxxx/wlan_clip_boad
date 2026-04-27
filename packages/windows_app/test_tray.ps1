# Windows 托盘功能快速测试脚本 (PowerShell)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows 托盘功能快速测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 获取依赖
Write-Host "[1/2] 获取依赖..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依赖获取失败" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 步骤 2: 运行应用
Write-Host "[2/2] 启动应用进行测试..." -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 测试步骤：" -ForegroundColor Green
Write-Host "  1. 等待应用窗口出现" -ForegroundColor White
Write-Host "  2. 点击窗口右上角的关闭按钮 (X)" -ForegroundColor White
Write-Host "  3. 检查系统托盘（右下角）是否出现图标" -ForegroundColor White
Write-Host "  4. 左键点击托盘图标 → 应显示窗口" -ForegroundColor White
Write-Host "  5. 右键点击托盘图标 → 应弹出菜单" -ForegroundColor White
Write-Host "  6. 选择'退出' → 应完全退出应用" -ForegroundColor White
Write-Host ""
Write-Host "按 Ctrl+C 可以停止应用" -ForegroundColor Gray
Write-Host ""

flutter run -d windows
