# 📱💻 Android 语音 → Windows 剪贴板同步方案 (WiFi 无线版)

## 🎯 项目简介

通过 **WiFi 局域网** 实现 Android 语音输入自动同步到 Windows 剪贴板，无需 USB 线连接。

### 核心优势
- 📡 **无线连接**：无需 USB 线，手机和 PC 在同一 WiFi 即可
- ⚡ **低延迟**：局域网直连，延迟通常 < 50ms
- 🔧 **可配置**：Android 端可设置 PC IP 地址，自动保存
- 📦 **单一项目**：Windows + Android 共用一套代码库
- 🖥️ **后台可用**：Win32 API 不受窗口焦点限制

---

## 📋 环境要求

| 组件 | 要求 |
|------|------|
| **Flutter SDK** | `3.16+` |
| **Android Studio / VS Code** | 已配置 Android 开发环境 |
| **Windows PC** | 已安装 Visual Studio (含 C++ 桌面开发) |
| **网络** | 手机和 PC 在同一 WiFi 网络 |

---

## 🚀 快速开始

### 方式一：一键启动（推荐）

双击运行 `start_sync.bat`，脚本会自动：
1. 检测本机 IP 地址
2. 提示防火墙配置
3. 启动 Windows 服务端
4. 启动 Android 客户端

### 方式二：手动启动

#### 1. 查看 PC IP 地址
```bash
ipconfig
```
找到 "IPv4 地址"，例如 `192.168.1.100`

#### 2. 配置防火墙（首次使用）
以管理员身份运行 CMD：
```bash
netsh advfirewall firewall add rule name="ClipSync" dir=in action=allow protocol=TCP localport=8889
```

#### 3. 启动 Windows 服务端
```bash
flutter run -d windows
```

#### 4. 启动 Android 客户端
```bash
flutter run -d <your_device_id>
```

#### 5. 在 Android 端配置 PC IP
1. 点击右上角 ⚙️ 设置图标
2. 输入 PC 的 IP 地址（步骤1中查到的）
3. 端口保持默认 8889
4. 点击"保存并重连"

---

## 📝 使用流程

1. **确保同一网络**：手机和 PC 连接到同一 WiFi
2. **启动 Windows 服务**：运行一键启动脚本或手动启动
3. **配置 Android 端**：点击右上角 ⚙️，输入 PC 的 IP 地址
4. **语音输入**：在 Android 端点击输入框 → 使用输入法语音输入
5. **自动同步**：停止输入 0.5 秒后自动发送至 Windows
6. **粘贴使用**：在 Windows 任意位置 `Ctrl+V` 粘贴

---

## 🏗️ 项目结构

```
packages/windows_app/
├── lib/
│   ├── main.dart                    # 主入口（平台自动路由）
│   ├── common/                      # 共享代码
│   │   ├── constants.dart           # 常量配置
│   │   └── utils.dart               # 工具类（防抖、日志）
│   ├── windows/                     # Windows 平台专用
│   │   ├── windows_server.dart      # WebSocket 服务器
│   │   └── clipboard_helper.dart    # Win32 剪贴板操作
│   └── android/                     # Android 平台专用
│       └── android_client.dart      # WebSocket 客户端（带IP配置）
├── android/                         # Android 平台配置
├── windows/                         # Windows 平台配置
├── start_sync.bat                   # 一键启动脚本
├── build_release.bat                # 打包发布脚本
├── pubspec.yaml                     # 依赖配置
└── README.md                        # 本文件
```

---

## 🔧 技术架构

### 数据流
```
Android 语音输入 
    ↓ (文本)
Android WebSocket Client (配置 PC IP:8889)
    ↓ (通过 WiFi 局域网)
Windows WebSocket Server (监听 0.0.0.0:8889)
    ↓ (接收文本)
Win32 API 写入 Windows 剪贴板
    ↓
用户 Ctrl+V 粘贴使用
```

### 关键依赖
- `web_socket_channel`: WebSocket 通信
- `win32`: 直接操作 Windows 剪贴板 API
- `shared_preferences`: 保存 PC IP 配置

---

## ⚠️ 常见问题

### 1. 无法连接到服务器
**症状**：Android 端显示"连接失败"

**解决**：
1. 确认手机和 PC 在同一 WiFi 网络
2. 确认 PC IP 地址正确（运行 `ipconfig` 查看）
3. 确认 Windows 防火墙允许端口 8889
4. 确认 Windows 服务端已启动

### 2. 端口被占用
**症状**：Windows 端启动时提示端口 8889 已被占用

**解决**：
```bash
# 查找占用端口的进程
netstat -ano | findstr :8889

# 结束进程（替换 PID 为实际值）
taskkill /F /PID <PID>
```

### 3. 输入法不显示麦克风
**症状**：键盘上没有语音输入按钮

**解决**：
- 使用 Gboard、搜狗、微信键盘等支持语音的输入法
- 在键盘设置中开启"语音输入"功能

### 4. 如何查看 PC IP 地址
**Windows**:
```bash
ipconfig
```
找到 "无线局域网适配器 WLAN" 下的 "IPv4 地址"

**macOS/Linux**:
```bash
ifconfig | grep inet
```

### 5. 跨网段无法连接
**症状**：手机和 PC 在不同子网

**解决**：
- 确保两者连接到同一路由器/AP
- 检查路由器是否启用了 AP 隔离（需关闭）

---

## 🎨 进阶优化

### 固定 IP 地址
建议在路由器中为 PC 设置静态 IP，避免 IP 变化后需要重新配置。

### 开机自启 + 托盘隐藏
如需将 Windows 端改为托盘应用，可添加：
```yaml
dependencies:
  bitsdojo_window: ^0.1.6
  system_tray: ^2.0.3
```

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**享受高效的跨端剪贴板同步体验！** 🎉
