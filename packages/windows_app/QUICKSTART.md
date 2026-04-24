# 🚀 快速开始指南 (WiFi 无线版)

## 前置检查清单

在运行项目之前，请确保：

- [ ] 已安装 Flutter SDK (3.16+)
- [ ] 已安装 Android Studio 或 VS Code
- [ ] 手机和 PC 连接到同一 WiFi 网络
- [ ] 已获取 PC 的 IP 地址（运行 `ipconfig` 查看）
- [ ] Windows 防火墙已允许端口 8889（首次使用）

## 验证环境

```bash
# 检查 Flutter
flutter doctor

# 查看 PC IP 地址
ipconfig
```

## 首次运行

### 步骤 1: 获取依赖

```bash
cd packages/windows_app
flutter pub get
```

### 步骤 2: 配置防火墙（首次使用）

以管理员身份运行 CMD：

```bash
netsh advfirewall firewall add rule name="ClipSync" dir=in action=allow protocol=TCP localport=8889
```

### 步骤 3: 运行一键启动脚本

双击 `start_sync.bat` 或在命令行执行：

```bash
start_sync.bat
```

脚本会自动完成：
1. ✅ 检测本机 IP 地址
2. ✅ 提示防火墙配置
3. ✅ 启动 Windows 服务端
4. ✅ 启动 Android 客户端

### 步骤 4: 在 Android 端配置 PC IP

1. 点击右上角 ⚙️ 设置图标
2. 输入 PC 的 IP 地址（步骤3中显示的）
3. 端口保持默认 8889
4. 点击"保存并重连"

### 步骤 5: 测试同步

1. 在 Android 端点击输入框
2. 使用输入法语音输入（点击麦克风图标）
3. 说完后停顿 0.5 秒
4. 在 Windows 任意位置按 `Ctrl+V` 粘贴

## 手动运行（可选）

如果不想使用一键脚本，可以手动执行：

```bash
# 终端 1: 启动 Windows 端
flutter run -d windows

# 终端 2: 启动 Android 端
flutter run -d <your_device_id>
```

然后在 Android 端点击右上角 ⚙️ 配置 PC IP 地址。

## 常见问题速查

### ❌ 连接失败
- 确认手机和 PC 在同一 WiFi 网络
- 确认 PC IP 地址正确
- 确认 Windows 防火墙允许端口 8889
- 确认 Windows 服务端已启动

### ❌ 端口 8889 被占用
```bash
# 查找占用进程
netstat -ano | findstr :8889

# 结束进程（替换 PID）
taskkill /F /PID <PID>
```

### ❌ 输入法没有麦克风图标
- 切换到 Gboard、搜狗或微信键盘
- 在键盘设置中开启"语音输入"功能

### ❌ 如何查看 PC IP
```bash
ipconfig
```
找到 "无线局域网适配器 WLAN" 下的 "IPv4 地址"

## 开发提示

### 热重载
修改代码后，在运行的终端按 `r` 进行热重载，无需重新启动。

### 查看日志
```bash
# Android 日志
flutter logs -d <device_id>

# Windows 日志
直接在控制台查看
```

### 清理构建
```bash
flutter clean
flutter pub get
```

## 下一步

- 阅读 [README.md](README.md) 了解完整文档
- 查看 [lib/common/constants.dart](lib/common/constants.dart) 修改配置
- 探索进阶功能：托盘应用、静态 IP 等

---

**祝你使用愉快！** 🎉
