# 📱💻 Clip Sync WiFi - 跨平台剪贴板同步系统

> 利用 **WiFi 局域网 WebSocket 通信** 实现 **Android 语音输入 → Windows 自动输入/剪贴板同步** 的跨平台解决方案

---

## 📋 目录

- [项目简介](#-项目简介)
- [核心架构](#-核心架构)
- [Monorepo 项目结构](#-monorepo-项目结构)
- [环境准备](#-环境准备)
- [快速开始](#-快速开始)
- [功能特性](#-功能特性)
- [网络配置](#-网络配置)
- [使用指南](#-使用指南)
- [Release 发布](#-release-发布)
- [开发指南](#-开发指南)
- [常见问题](#-常见问题)
- [技术栈](#-技术栈)

---

## 🎯 项目简介

Clip Sync WiFi 是一个基于 Flutter 的跨平台剪贴板同步系统，采用 Monorepo 架构，包含三个独立但协同工作的子项目：

1. **Windows 应用** (`clip_sync_wifi`) - WebSocket 服务器，接收文本并自动输入或写入剪贴板
2. **Android 应用** (`clip_sync_android`) - WebSocket 客户端，支持语音识别和文本发送
3. **共享代码包** (`clip_sync_common`) - 跨平台共享的常量和工具类

### 核心优势

- ✅ **无线同步** - 无需 USB 线缆，通过 WiFi 局域网连接
- ✅ **自动输入** - Windows 端可直接将文本输入到当前焦点窗口
- ✅ **悬浮窗模式** - 窗口可置顶，方便实时监控
- ✅ **模块化折叠** - UI 模块可折叠，界面简洁灵活
- ✅ **IP 地址显示** - 自动检测并显示本机局域网 IP
- ✅ **代码复用** - Monorepo 架构，共享逻辑集中管理

---

## 🏗️ 核心架构

```
[Android Flutter] 语音输入/文本编辑
│ 文本流
▼
[WebSocket Client] ──(WiFi: PC_IP:8889)──┐
│ 局域网 TCP 连接                          │
[WebSocket Server] ◀─────────────────────┘
│ 接收文本
▼
┌─────────────────────────────┐
│  Windows 处理流程            │
├─────────────────────────────┤
│ 1. 自动输入模式              │
│    ├─ 粘贴方式 (Ctrl+V)     │
│    └─ 逐字符输入            │
│ 2. 剪贴板模式                │
│    └─ 写入系统剪贴板         │
└─────────────────────────────┘
```

---

## 📁 Monorepo 项目结构

```
mobileClipbordBridge/
├── packages/
│   ├── common/                    # 📦 共享代码包
│   │   ├── lib/
│   │   │   ├── constants.dart          # 常量定义（端口、协议等）
│   │   │   ├── utils.dart              # 工具类（日志、防抖等）
│   │   │   └── clip_sync_common.dart   # 包导出文件
│   │   └── pubspec.yaml
│   │
│   ├── windows_app/               # 💻 Windows 应用
│   │   ├── lib/
│   │   │   ├── windows/
│   │   │   │   ├── windows_server.dart        # WebSocket 服务器
│   │   │   │   ├── clipboard_helper.dart      # 剪贴板操作
│   │   │   │   ├── keyboard_input_helper.dart # 键盘输入模拟
│   │   │   │   └── tray_manager.dart          # 系统托盘管理
│   │   │   └── main.dart
│   │   ├── windows/                 # Windows 原生项目
│   │   │   ├── runner/
│   │   │   │   ├── main.cpp         # 窗口配置（尺寸 380x700）
│   │   │   │   └── ...
│   │   │   └── CMakeLists.txt
│   │   ├── release/
│   │   │   └── windows/             # Release 构建产物
│   │   │       ├── clip_sync_wifi.exe
│   │   │       ├── flutter_windows.dll
│   │   │       └── data/
│   │   ├── build_release.bat        # Windows 构建脚本
│   │   ├── start_sync.bat           # 快速启动脚本
│   │   └── pubspec.yaml
│   │
│   └── android_app/                 # 📱 Android 应用
│       ├── lib/
│       │   ├── android/
│       │   │   └── android_client.dart      # WebSocket 客户端
│       │   └── main.dart
│       ├── android/                 # Android 原生项目
│       ├── release/
│       │   └── android/             # Release 构建产物
│       │       └── clip_sync_android.apk
│       ├── build_release.bat        # Android 构建脚本
│       └── pubspec.yaml
│
├── README.md                        # 本文档
└── .gitignore
```

### 设计原则

1. **平台隔离** - 每个平台只包含自己的专用代码
   - Windows: `win32` API、键盘模拟
   - Android: 语音识别、移动端 UI
   
2. **代码复用** - 共享逻辑放在 `common` 包
   - 常量定义（端口号、协议）
   - 工具类（日志、防抖）
   
3. **独立构建** - 每个平台可单独构建，互不影响

---

## 📦 环境准备

| 组件 | 要求 |
|------|------|
| **Flutter SDK** | `3.16+` |
| **Android Studio / VS Code** | 已配置 Android 开发环境 |
| **Windows PC** | Windows 10/11，连接到局域网 |
| **Android 设备** | Android 7.0+，与 PC 同一局域网 |
| **网络连通性** | PC 和手机可互相访问（防火墙允许端口 8889） |

### 验证网络

在 Android 设备上 ping PC 的 IP 地址，确保网络通畅。

---

## 🚀 快速开始

### 方法 1：使用构建好的 Release 版本（推荐）

#### Windows 端

1. 进入 `packages/windows_app/release/windows/` 目录
2. 双击运行 `clip_sync_wifi.exe`
3. 记录显示的局域网 IP 地址（如 `192.168.1.168`）

#### Android 端

1. 将 `packages/android_app/release/android/clip_sync_android.apk` 传输到手机
2. 安装 APK
3. 打开应用，点击右上角 ⚙️ 设置图标
4. 输入 Windows 端的 IP 地址
5. 点击"连接到 PC"

### 方法 2：从源码构建

#### 构建 Windows 应用

```bash
cd packages/windows_app
.\build_release.bat
```

构建完成后，文件位于：`release/windows/clip_sync_wifi.exe`

#### 构建 Android 应用

```bash
cd packages/android_app
.\build_release.bat
```

构建完成后，文件位于：`release/android/clip_sync_android.apk`

### 方法 3：开发模式运行

#### Windows 开发

```bash
cd packages/windows_app
flutter pub get
flutter run -d windows
```

#### Android 开发

```bash
cd packages/android_app
flutter pub get
flutter run -d <device-id>
```

查看设备列表：`flutter devices`

---

## ✨ 功能特性

### Windows 应用特性

#### 1. 双输入模式

- **📋 剪贴板模式** - 文本写入剪贴板，手动 Ctrl+V 粘贴
- **⌨️ 自动输入模式**（默认开启）- 直接输入到当前焦点窗口
  - **粘贴方式** (Ctrl+V) - 快速准确，适合长文本（推荐）
  - **逐字符输入** - 兼容性好，但速度较慢

#### 2. 悬浮窗模式

- 📌 窗口可设置为"始终置顶"
- 在其他应用工作时仍可查看同步内容
- 适合演示和多任务场景

#### 3. 实时文本显示

- 📝 接收的文本实时显示在界面中
- 默认展开，立即可见
- 支持一键复制

#### 4. 模块折叠

- 所有功能模块支持折叠/展开
- "接收的文本"默认展开
- 其他模块默认折叠，减少视觉干扰
- 点击标题栏切换状态

#### 5. IP 地址显示

- 自动检测本机局域网 IP
- 一键复制 IP 地址
- 方便 Android 端配置连接

#### 6. 系统托盘

- 最小化到系统托盘
- 后台持续运行
- 右键菜单快速操作

### Android 应用特性

- ✅ 语音识别转文字
- ✅ WebSocket 客户端连接
- ✅ 可配置 PC IP 地址
- ✅ 自动重连机制
- ✅ 连接状态显示
- ✅ 防抖优化（停止输入 500ms 后发送）

---

## 🔌 网络配置

### 步骤 1: 获取 PC 的 IP 地址

在 Windows PowerShell 或 CMD 中执行：

```bash
ipconfig
```

找到当前网络连接（以太网或 WLAN），记录 **IPv4 地址**，例如：`192.168.1.168`

### 步骤 2: 配置防火墙规则

确保 Windows 防火墙允许端口 8889 的入站连接：

```powershell
# PowerShell (管理员权限)
New-NetFirewallRule -DisplayName "ClipSync WiFi" -Direction Inbound -LocalPort 8889 -Protocol TCP -Action Allow
```

或在 Windows 防火墙设置中手动添加入站规则。

### 步骤 3: 验证网络连通性

在 Android 设备上：
1. 打开浏览器
2. 访问 `http://<PC_IP>:8889`
3. 如果能连接（即使返回错误），说明网络通畅

### 常见问题排查

| 问题 | 解决方案 |
|------|----------|
| **无法连接到 PC** | 1. 确认 PC 和手机在同一局域网<br>2. 检查防火墙是否允许 8889 端口<br>3. 验证 IP 地址是否正确<br>4. 用手机浏览器测试连接 |
| **端口被占用** | `netstat -ano \| findstr :8889` 找到 PID，结束进程 |
| **连接频繁断开** | 1. 检查 WiFi 信号强度<br>2. 关闭路由器 AP 隔离<br>3. 使用 5GHz WiFi 频段 |
| **IP 地址经常变化** | 在路由器中为 PC 设置静态 IP（DHCP 保留） |

---

## 📖 使用指南

### 工作流程

1. **启动 Windows 服务器**
   ```bash
   cd packages/windows_app
   flutter run -d windows
   ```
   - 记录显示的 IP 地址（如 `192.168.1.168`）
   - 窗口尺寸：380 x 700 像素

2. **配置 Android 客户端**
   - 打开 Android 应用
   - 点击右上角 ⚙️ 设置图标
   - 输入 Windows 端的 IP 地址
   - 点击"连接到 PC"

3. **开始同步**
   - 在 Android 端说话或输入文本
   - 停顿 0.5 秒（防抖）
   - 文本自动发送到 Windows 端
   - Windows 端根据设置自动输入或写入剪贴板

### Windows 端界面说明

```
┌──────────────────────────────┐
│ ClipSync WiFi                │
├──────────────────────────────┤
│ 🖥️ 服务器状态          [▶]   │ ← 折叠（点击展开）
│ 📝 接收的文本          [▼]   │ ← 展开（默认）
│ ┌──────────────────────────┐ │
│ │ 等待接收文本...          │ │
│ └──────────────────────────┘ │
│ ⌨️ 输入模式            [▶]   │ ← 折叠
│ 📌 窗口设置            [▶]   │ ← 折叠
│ 💡 使用说明            [▶]   │ ← 折叠
│ 📜 连接日志            [▶]   │ ← 折叠
└──────────────────────────────┘
```

### 输入模式选择

在 Windows 应用界面中：

1. 展开"⌨️ 输入模式"模块
2. 选择模式：
   - **自动输入模式** - 直接输入到焦点窗口
     - 子选项：**使用粘贴方式 (Ctrl+V)** - 推荐
   - **剪贴板模式** - 仅写入剪贴板

### 悬浮窗模式

1. 展开"📌 窗口设置"模块
2. 开启"悬浮窗模式"开关
3. 窗口将始终保持在最前面

---

## 📦 Release 发布

### 目录结构

每个平台的 `release/` 目录**只包含该平台**的构建产物：

#### Android
```
packages/android_app/release/
└── android/
    └── clip_sync_android.apk
```

#### Windows
```
packages/windows_app/release/
└── windows/
    ├── clip_sync_wifi.exe
    ├── flutter_windows.dll
    └── data/
        └── flutter_assets/
```

### 构建命令

#### Android
```bash
cd packages/android_app
.\build_release.bat
```

#### Windows
```bash
cd packages/windows_app
.\build_release.bat
```

### Git 忽略规则

已配置 `.gitignore` 只跟踪对应平台的子目录：

```gitignore
# Android
/release/*
!/release/android/

# Windows
/release/*
!/release/windows/
```

### 统一打包（可选）

如需创建包含两个平台的发布包：

```bash
mkdir release_package
copy packages\android_app\release\android\* release_package\android\
xcopy /E /I packages\windows_app\release\windows\* release_package\windows\
```

---

## 👨‍💻 开发指南

### Monorepo 架构

本项目采用 Monorepo 结构，包含三个独立的包：

1. **common** - 共享代码包
2. **windows_app** - Windows 应用
3. **android_app** - Android 应用

### 依赖管理

每个应用通过 `path dependency` 引用 common 包：

```yaml
dependencies:
  clip_sync_common:
    path: ../common
```

### 修改共享代码

1. 在 `packages/common/lib/` 中修改代码
2. 在两个应用中分别运行 `flutter pub get` 更新依赖
3. 重新构建应用

```bash
# 修改 common 后
cd packages/windows_app
flutter pub get

cd ../android_app
flutter pub get
```

### 添加新功能

**如果功能是跨平台的：**
- 添加到 `packages/common/lib/`
- 在 `clip_sync_common.dart` 中导出

**如果功能是平台专用的：**
- Windows: 添加到 `packages/windows_app/lib/windows/`
- Android: 添加到 `packages/android_app/lib/android/`

### 导入方式

在应用中使用 common 包：

```dart
import 'package:clip_sync_common/clip_sync_common.dart';
```

### 平台隔离

- ✅ Windows 应用可以安全地使用 `win32` 包
- ✅ Android 应用完全不接触 Windows 专用代码
- ✅ 编译时不会出现跨平台错误

---

## ❓ 常见问题

### Q1: Android 构建失败？

**A:** 确保 `packages/android_app` 中没有引用 Windows 专用代码（win32）。检查 `pubspec.yaml` 中是否有多余的依赖。

### Q2: Windows 构建失败？

**A:** 
1. 检查 `win32` 包版本兼容性
2. 确保没有正在运行的旧版本应用
3. 清理后重新构建：`flutter clean && flutter pub get`

### Q3: 如何调试共享代码？

**A:** 在 `packages/common` 中修改后，需要在两个应用中分别运行 `flutter pub get`

### Q4: 输入法不显示麦克风？

**A:** 确保使用 Gboard、搜狗、微信键盘等支持语音的输入法，并在键盘设置中开启"语音输入"。

### Q5: 后台写入剪贴板失败？

**A:** 代码已使用 `win32` 原生 API，无需窗口焦点。若仍失败，检查 Windows 安全软件是否拦截剪贴板操作。

### Q6: 布局溢出错误？

**A:** 已修复！主 Column 包裹在 `SingleChildScrollView` 中，所有内容可滚动访问。

### Q7: 窗口太小看不清？

**A:** 窗口尺寸可在 `windows/runner/main.cpp` 中修改：
```cpp
Win32Window::Size size(380, 700);  // 宽度 380px，高度 700px
```

---

## 🛠️ 技术栈

### 核心框架
- **Flutter** - 跨平台 UI 框架
- **Dart** - 编程语言

### 通信
- **WebSocket** (`web_socket_channel`) - 实时双向通信
- **TCP/IP** - 局域网传输协议

### Windows 专用
- **Win32 API** (`win32`) - 剪贴板操作、键盘模拟
- **FFI** (`ffi`) - 调用 Windows API
- **bitsdojo_window** - 窗口管理
- **system_tray** - 系统托盘

### Android 专用
- **Speech Recognition** - 语音识别
- **SharedPreferences** - 配置持久化

### 工具
- **CMake** - Windows 原生构建
- **Gradle** - Android 原生构建

---

## 📊 性能对比

| 特性 | USB ADB 方案 | WiFi 局域网方案 |
|------|-------------|----------------|
| **延迟** | < 10ms | 10-50ms (取决于网络) |
| **稳定性** | 依赖 USB 线缆 | 依赖 WiFi 质量 |
| **灵活性** | 需要数据线连接 | 无线，自由移动 |
| **配置复杂度** | 需要 ADB 环境 | 只需 IP 地址 |
| **多设备支持** | 每台设备需单独转发 | 多设备同时连接 |
| **适用场景** | 开发调试 | 日常使用 |

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📝 更新日志

### v2.0 (2026-04-23)
- ✅ Monorepo 架构重构
- ✅ 模块折叠功能
- ✅ 悬浮窗模式
- ✅ IP 地址自动显示
- ✅ 自动输入功能优化
- ✅ Release 目录标准化
- ✅ 项目名称修正为 clip_sync_wifi

### v1.0
- ✅ 基础 WebSocket 通信
- ✅ 剪贴板同步
- ✅ 语音识别

---

**💡 提示**: 保持 Windows 服务端最小化运行即可，Android 端可随时连接/断开。

**Happy Coding! 🎉**
