# Android 调试命令指南

## Flutter Android 调试命令

### 1. 连接设备并运行

```bash
# 查看已连接的设备
flutter devices

# 在连接的 Android 设备上运行（调试模式）
flutter run

# 指定设备运行（如果有多个设备）
flutter run -d <device_id>
```

### 2. 构建 APK

```bash
# 构建调试 APK
flutter build apk --debug

# 构建发布 APK
flutter build apk --release

# 构建 App Bundle（推荐用于发布）
flutter build appbundle --release
```

### 3. 日志查看

```bash
# 实时查看日志
flutter logs

# 或者使用 adb 查看日志
adb logcat

# 过滤特定标签的日志
adb logcat -s "Flutter"

# 清除日志后重新查看
adb logcat -c && adb logcat
```

### 4. 热重载和热重启（在 flutter run 运行时）

- `r` - 热重载（Hot Reload）
- `R` - 热重启（Hot Restart）
- `p` - 切换性能覆盖层
- `w` - 打印 widget 层级
- `q` - 退出

### 5. ADB 常用命令

```bash
# 查看连接的设备
adb devices

# 重启 adb 服务
adb kill-server && adb start-server

# 无线调试连接（需要先在开发者选项中启用）
adb connect <ip_address>:5555

# 安装 APK
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# 清除应用数据
adb shell pm clear <package_name>

# 启动应用
adb shell am start -n <package_name>/<activity_name>
```

### 6. 调试特定问题

```bash
# 检查 Flutter 环境
flutter doctor

# 详细输出（用于排查问题）
flutter run -v

# 清理构建缓存
flutter clean
flutter pub get
```

## 常见问题排查

### 设备未识别
1. 确保手机已开启开发者选项和 USB 调试
2. 运行 `adb devices` 检查设备是否列出
3. 尝试重新插拔 USB 线或重启 adb 服务

### 构建失败
1. 运行 `flutter clean` 清理缓存
2. 运行 `flutter pub get` 重新获取依赖
3. 运行 `flutter doctor` 检查环境配置

### 网络连接问题
1. 确保手机和 PC 在同一网络
2. 检查防火墙设置
3. 使用 `adb connect` 进行无线调试时，确保端口正确
