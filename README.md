# 📱💻 Android 语音 → Windows 剪贴板同步方案 (WiFi 局域网版)

本方案利用 **WiFi 局域网 WebSocket 通信** 实现 **跨平台、灵活配置、稳定可靠** 的 Android 到 Windows 剪贴板同步。全程基于单一 Flutter 项目实现。

---

## 🎯 核心架构

```
[Android Flutter] 输入框(系统语音键盘)
│ 文本流
▼
[WebSocket Client] ──(WiFi: PC_IP:8080)──┐
│ 局域网 TCP 连接
[WebSocket Server] ◀──(0.0.0.0:8080)────┘
│ 接收文本
▼
[Win32 API] → 写入 Windows 系统剪贴板
```

---

## 📦 1. 环境准备

| 组件                           | 要求                                         |
|------------------------------|--------------------------------------------|
| **Flutter SDK**              | `3.16+`                                    |
| **Android Studio / VS Code** | 已配置 Android 开发环境                           |
| **Windows PC**               | 连接到局域网（有线或 WiFi 均可）                      |
| **Android 设备**               | 连接到与 PC **同一局域网**（同一 WiFi 或路由器）         |
| **网络连通性**                  | PC 和手机之间可以互相访问（关闭防火墙或允许端口 8080）       |
| **验证连接**                     | 手机上可 ping 通 PC 的 IP 地址                    |

---

## 📝 2. 项目创建与依赖

```bash
flutter create clip_sync_wifi
cd clip_sync_wifi
```

编辑 `pubspec.yaml`，添加依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  web_socket_channel: ^2.4.0      # WebSocket 通信
  win32: ^5.2.0                   # 稳定写入 Windows 剪贴板(后台可用)
  shared_preferences: ^2.2.2      # 保存 PC IP 配置
```

执行 `flutter pub get`

---

## 💻 3. 完整核心代码

项目采用平台自动路由，**无需分别维护两套入口**。主要文件结构：

```
lib/
├── main.dart                          # 应用入口，平台判断
├── constants.dart                     # 常量定义（默认端口等）
├── windows/
│   └── windows_server.dart           # Windows 服务端逻辑
└── android/
    └── android_client.dart           # Android 客户端逻辑
```

### 关键特性

- ✅ **可配置的 PC IP 地址** - 通过设置界面修改
- ✅ **自动重连机制** - 断线后自动尝试重新连接
- ✅ **防抖优化** - 停止输入 500ms 后发送，避免碎片化
- ✅ **连接状态显示** - 实时显示 WiFi 连接状态

---

## 🔌 4. 网络连接配置 (关键)

### 步骤 1: 获取 PC 的 IP 地址

在 Windows **PowerShell 或 CMD** 中执行：

```bash
ipconfig
```

找到当前网络连接（以太网或 WLAN），记录 **IPv4 地址**，例如：`192.168.1.100`

### 步骤 2: 配置防火墙规则

确保 Windows 防火墙允许端口 8080 的入站连接：

```bash
# PowerShell (管理员权限)
New-NetFirewallRule -DisplayName "ClipSync WebSocket" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

或在 Windows 防火墙设置中手动添加入站规则。

### 步骤 3: 验证网络连通性

在 Android 设备上：
1. 打开终端应用或使用浏览器
2. 访问 `http://<PC_IP>:8080`
3. 如果能连接（即使返回错误），说明网络通畅

---

## 🚀 5. 运行与测试指南

| 步骤 | 操作 |
|------|------|
| **① 启动 Windows 服务** | `flutter run -d windows` |
| **② 配置 PC IP** | 在 Android 应用中点击右上角 ⚙️，输入 PC 的 IP 地址 |
| **③ 启动 Android 客户端** | `flutter run -d <your_device_id>` |
| **④ 建立连接** | 点击「连接到 PC」按钮 |
| **⑤ 测试同步** | 手机点击输入框 → 使用输入法语音 → 停顿 0.5s → 在 Windows 任意位置 `Ctrl+V` |

### 快速启动脚本

项目根目录提供了便捷的启动脚本：

```bash
# Windows (PowerShell)
.\start_windows.ps1

# Android
.\start_android.ps1
```

---

## ⚠️ 6. 避坑指南 & 进阶优化

| 问题 | 解决方案 |
|------|----------|
| **无法连接到 PC** | 1. 确认 PC 和手机在同一局域网<br>2. 检查 PC 防火墙是否允许 8080 端口<br>3. 验证 IP 地址是否正确（`ipconfig`）<br>4. 尝试用手机浏览器访问 `http://PC_IP:8080` 测试 |
| **端口被占用** | `netstat -ano \| findstr :8080` 找到 PID，任务管理器结束进程，或修改代码中的端口号 |
| **连接频繁断开** | 1. 检查 WiFi 信号强度<br>2. 路由器可能启用了 AP 隔离，需关闭<br>3. 尝试使用 5GHz WiFi 频段更稳定 |
| **输入法不显示麦克风** | 确保使用 Gboard、搜狗、微信键盘等支持语音的输入法，并在键盘设置中开启"语音输入" |
| **后台写入剪贴板失败** | 代码已使用 `win32` 原生 API，无需窗口焦点。若仍失败，检查 Windows 安全软件是否拦截剪贴板操作 |
| **IP 地址经常变化** | 在路由器中为 PC 设置静态 IP（DHCP 保留），或使用内网域名 |
| **想要开机自启+托盘隐藏** | 添加 `bitsdojo_window` + `system_tray` 包，将 Windows 端改为托盘应用，隐藏主窗口 |

---

## 📊 7. 性能对比

| 特性 | USB ADB 方案 | WiFi 局域网方案 |
|------|-------------|----------------|
| **延迟** | < 10ms | 10-50ms (取决于网络) |
| **稳定性** | 依赖 USB 线缆 | 依赖 WiFi 质量 |
| **灵活性** | 需要数据线连接 | 无线，自由移动 |
| **配置复杂度** | 需要 ADB 环境 | 只需 IP 地址 |
| **多设备支持** | 每台设备需单独转发 | 多设备同时连接 |
| **适用场景** | 开发调试 | 日常使用 |

---

## 🛠️ 8. 技术栈

- **Flutter**: 跨平台 UI 框架
- **WebSocket**: 实时双向通信
- **Win32 API**: Windows 剪贴板操作
- **SharedPreferences**: Android 端配置持久化
- **TCP/IP**: 局域网传输协议

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**💡 提示**: 保持 Windows 服务端最小化运行即可，Android 端可随时连接/断开。
