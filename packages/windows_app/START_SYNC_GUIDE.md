# 📖 start_sync.bat 使用说明

## ⚠️ 重要提示

**不要复制 `.bat` 文件的内容到 PowerShell 中执行！**

`.bat` 文件是 Windows 批处理脚本，必须作为文件执行，而不是复制内容。

---

## ✅ 正确的使用方法

### 方法 1：双击运行（最简单）
1. 打开文件资源管理器
2. 导航到 `packages\windows_app\` 目录
3. 双击 `start_sync.bat` 文件

### 方法 2：命令行运行
```bash
# 在 CMD 中
cd packages\windows_app
start_sync.bat

# 或在 PowerShell 中
cd packages\windows_app
.\start_sync.bat
```

### 方法 3：右键菜单
1. 右键点击 `start_sync.bat`
2. 选择"以管理员身份运行"（如需配置防火墙）

---

## 🔧 脚本功能

### 1. 自动获取本机 IP
```
[1/3] Getting local IP address...
[OK] Local IP: 192.168.1.168
```
自动检测你的电脑 IP 地址，方便 Android 端连接。

### 2. 防火墙提示
```
[2/3] Firewall settings...
Note: Ensure port 8889 is allowed in Windows Firewall
```
提醒你需要允许端口 8889 通过防火墙。

### 3. 启动 Windows 服务器
```
[3/3] Starting Windows server...
Starting Clip Sync WiFi server...
```
在新窗口中启动 Flutter 应用（Debug 模式）。

---

## 📋 使用流程

### 首次使用

1. **运行脚本**
   ```bash
   .\start_sync.bat
   ```

2. **按任意键启动**
   - 脚本会显示 IP 地址和使用说明
   - 按任意键继续

3. **等待 Windows 应用启动**
   - 会打开一个新窗口
   - 显示 "WebSocket 服务器已启动"

4. **安装 Android APK**
   ```bash
   adb install release\android\clip_sync_android.apk
   ```

5. **配置 Android 端**
   - 打开 Android 应用
   - 点击设置（齿轮图标）
   - 输入显示的 IP 地址（如 192.168.1.168）
   - 端口：8889
   - 点击连接

### 日常使用

1. 确保手机和 PC 在同一 WiFi 网络
2. 运行 `start_sync.bat`
3. 启动 Android 应用
4. 开始使用剪贴板同步

---

## ❌ 常见错误

### 错误 1：PowerShell 解析错误
```
ParserError:
Line |
   1 |  @echo off
     |        ~~~
     | Unexpected token 'off' in expression or statement.
```

**原因**：复制了 `.bat` 文件内容到 PowerShell

**解决**：直接运行文件，不要复制内容
```bash
# 正确做法
.\start_sync.bat

# 错误做法
@echo off  # ← 不要这样做
```

### 错误 2：中文乱码
如果看到乱码，是因为编码问题。

**解决**：已更新为英文版本，重新下载文件即可。

### 错误 3：找不到文件
```
系统找不到指定的路径。
```

**原因**：当前目录不正确

**解决**：先切换到正确目录
```bash
cd packages\windows_app
.\start_sync.bat
```

---

## 🔍 脚本内容说明

### 主要步骤

1. **获取 IP 地址**
   ```batch
   for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
       set "LOCAL_IP=%%b"
   )
   ```

2. **显示防火墙信息**
   ```batch
   echo Note: Ensure port 8889 is allowed in Windows Firewall
   ```

3. **启动应用**
   ```batch
   start "ClipSync-Windows" cmd /k "cd /d %~dp0 && flutter run -d windows"
   ```
   - `cmd /k` - 保持窗口打开
   - `cd /d %~dp0` - 切换到脚本所在目录
   - `flutter run -d windows` - 运行 Flutter 应用

---

## 💡 高级用法

### 仅启动 Release 版本
如果想直接运行编译好的 EXE：
```bash
release\windows\clip_sync_wifi.exe
```

### 配置防火墙规则
以管理员身份运行 CMD：
```bash
netsh advfirewall firewall add rule name="ClipSync" dir=in action=allow protocol=TCP localport=8889
```

### 查看本机 IP
```bash
ipconfig
```

---

## 📞 故障排除

### 问题 1：IP 地址显示 unknown
**解决**：手动运行 `ipconfig` 查看 IPv4 地址

### 问题 2：无法连接
**检查**：
1. 手机和 PC 是否在同一 WiFi
2. 防火墙是否允许端口 8889
3. IP 地址是否正确

### 问题 3：Flutter 命令找不到
**解决**：确保 Flutter 已添加到系统 PATH

---

## 🎯 快速开始

```bash
# 1. 进入目录
cd packages\windows_app

# 2. 运行脚本
.\start_sync.bat

# 3. 按任意键启动

# 4. 在新窗口中看到服务器启动

# 5. 安装 Android APK
adb install release\android\clip_sync_android.apk

# 6. 在 Android 应用中输入 IP 并连接
```

---

**更新时间**: 2026-04-24  
**版本**: v2.1.0  
**语言**: English (避免编码问题)
