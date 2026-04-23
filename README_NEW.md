# Clip Sync - 跨平台剪贴板同步系统

## 📁 项目结构

这是一个 Monorepo 项目，包含三个子项目：

```
mobileClipbordBridge/
├── packages/
│   ├── common/              # 📦 共享代码包
│   │   ├── lib/
│   │   │   ├── constants.dart    # 常量定义
│   │   │   ├── utils.dart        # 工具类
│   │   │   └── clip_sync_common.dart  # 包导出文件
│   │   └── pubspec.yaml
│   │
│   ├── windows_app/         # 💻 Windows 应用
│   │   ├── lib/
│   │   │   ├── windows/
│   │   │   │   ├── windows_server.dart      # WebSocket 服务器
│   │   │   │   ├── clipboard_helper.dart    # 剪贴板操作
│   │   │   │   └── keyboard_input_helper.dart # 键盘输入模拟
│   │   │   └── main.dart
│   │   └── pubspec.yaml
│   │
│   └── android_app/         # 📱 Android 应用
│       ├── lib/
│       │   ├── android/
│       │   │   └── android_client.dart      # WebSocket 客户端
│       │   └── main.dart
│       └── pubspec.yaml
│
└── README.md
```

## 🚀 快速开始

### 1️⃣ Windows 应用

```bash
cd packages/windows_app
flutter pub get
flutter run -d windows
```

**功能特性：**
- ✅ WebSocket 服务器监听
- ✅ 接收 Android 端文本
- ✅ 自动输入到当前焦点窗口（两种模式）
  - 粘贴方式（Ctrl+V）- 推荐
  - 逐字符输入
- ✅ 剪贴板同步模式

### 2️⃣ Android 应用

```bash
cd packages/android_app
flutter pub get
flutter run -d <your-android-device>
```

**功能特性：**
- ✅ 语音识别转文字
- ✅ WebSocket 客户端连接
- ✅ 发送文本到 Windows 端

### 3️⃣ 共享代码包

common 包包含两个平台共享的代码：
- `constants.dart` - 常量定义（端口号、协议等）
- `utils.dart` - 工具类（日志、防抖等）

## 🔧 开发指南

### 修改共享代码

1. 在 `packages/common/lib/` 中修改代码
2. 在两个应用中分别运行 `flutter pub get` 更新依赖
3. 重新构建应用

### 添加新功能

**如果功能是跨平台的：**
- 添加到 `packages/common/lib/`
- 在 `clip_sync_common.dart` 中导出

**如果功能是平台专用的：**
- Windows: 添加到 `packages/windows_app/lib/windows/`
- Android: 添加到 `packages/android_app/lib/android/`

## 📝 使用说明

### 工作流程

1. **启动 Windows 服务器**
   ```bash
   cd packages/windows_app
   flutter run -d windows
   ```
   - 记录显示的 IP 地址和端口

2. **配置 Android 客户端**
   - 打开 Android 应用
   - 输入 Windows 端的 IP 地址
   - 确保手机和 PC 在同一 WiFi 网络

3. **开始同步**
   - 在 Android 端说话或输入文本
   - 文本会自动发送到 Windows 端
   - Windows 端根据设置自动输入或写入剪贴板

### 输入模式选择（Windows 端）

在 Windows 应用界面中可以选择：

1. **📋 剪贴板模式**（默认）
   - 文本写入剪贴板
   - 手动按 Ctrl+V 粘贴

2. **⌨️ 自动输入模式**
   - 直接输入到当前焦点窗口
   - 子选项：
     - 粘贴方式（推荐）- 快速准确
     - 逐字符输入 - 兼容性好

## ⚙️ 技术栈

- **Flutter** - 跨平台 UI 框架
- **WebSocket** - 实时通信
- **Win32 API** - Windows 剪贴板和键盘模拟
- **Android Speech API** - 语音识别

## 🐛 常见问题

### Q: Android 构建失败？
A: 确保 `packages/android_app` 中没有引用 Windows 专用代码（win32）

### Q: Windows 构建失败？
A: 检查 `win32` 包版本兼容性，参考 `common_pitfalls_experience`

### Q: 如何调试共享代码？
A: 在 `packages/common` 中修改后，需要在两个应用中分别运行 `flutter pub get`

## 📄 许可证

本项目仅供学习和个人使用。

---

**Happy Coding! 🎉**
