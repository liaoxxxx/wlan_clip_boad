# 🌐 局域网 IP 地址显示功能

## ✅ 功能实现

### 功能描述
Windows 应用现在会在启动时自动检测并显示本机的局域网 IP 地址，方便 Android 端配置连接。

### 显示位置
在 **"🖥️ 服务器状态"** 卡片中，位于服务器状态信息下方。

---

## 🎯 界面效果

```
┌──────────────────────────────┐
│ 🖥️ 服务器状态                 │
├──────────────────────────────┤
│ ✅ 服务运行中                 │
│ 端口: 8889                   │
│                              │
│ 📶 局域网 IP: 192.168.1.168 [📋] │ ← 新增
└──────────────────────────────┘
```

### UI 元素
- **图标**: 📶 WiFi 图标（绿色）
- **标签**: "局域网 IP: "
- **IP 地址**: 等宽字体显示（Consolas）
- **复制按钮**: 📋 点击可复制 IP 地址

---

## 🔧 技术实现

### 1. 获取 IP 地址

使用 Dart 的 `NetworkInterface` API：

```dart
Future<void> _getLocalIP() async {
  try {
    // 获取所有网络接口
    final interfaces = await NetworkInterface.list(
      includeLinkLocal: false,
      includeLoopback: false,
    );
    
    // 查找 IPv4 地址
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          // 排除 127.0.0.1
          if (!addr.address.startsWith('127.')) {
            setState(() {
              _localIP = addr.address;
            });
            return;
          }
        }
      }
    }
  } catch (e) {
    // 错误处理
  }
}
```

### 2. 显示 IP 地址

```dart
Row(
  children: [
    const Icon(Icons.wifi, size: 16, color: Colors.greenAccent),
    const SizedBox(width: 4),
    const Text('局域网 IP: ', style: TextStyle(...)),
    Expanded(
      child: Text(_localIP, style: TextStyle(...)),
    ),
    IconButton(
      icon: const Icon(Icons.copy, size: 16),
      onPressed: () {
        _setClipboard(_localIP);
      },
    ),
  ],
)
```

---

## 💡 使用场景

### 场景 1: 首次配置
1. 启动 Windows 应用
2. 查看显示的 IP 地址（如 192.168.1.168）
3. 在 Android 应用中输入此 IP
4. 端口：8889
5. 点击连接

### 场景 2: IP 变更
如果路由器重新分配 IP：
1. 重启 Windows 应用
2. 查看新的 IP 地址
3. 更新 Android 端配置

### 场景 3: 快速复制
1. 点击 IP 地址旁边的复制按钮 📋
2. IP 地址已复制到剪贴板
3. 粘贴到 Android 应用或其他地方

---

## 📊 IP 地址状态

| 状态 | 显示内容 | 说明 |
|------|---------|------|
| 正在获取 | `获取中...` | 应用启动时短暂显示 |
| 成功获取 | `192.168.1.168` | 实际的局域网 IP |
| 未找到 | `未找到` | 没有可用的网络接口 |
| 获取失败 | `获取失败` | 发生错误 |

---

## 🎨 UI 设计

### 颜色方案
- **WiFi 图标**: 绿色（greenAccent）
- **IP 文字**: 白色
- **字体**: Consolas（等宽字体，便于阅读数字）

### 布局
- **左对齐**: 与其他状态信息一致
- **紧凑**: 不占用过多空间
- **清晰**: 图标 + 文字 + 复制按钮

---

## ⚠️ 注意事项

### 1. 多网卡情况
如果电脑有多个网络接口（有线、无线、虚拟网卡）：
- 会显示第一个找到的 IPv4 地址
- 通常是主要的网络连接

### 2. IP 地址类型
只显示**局域网 IP**（私有 IP）：
- ✅ 192.168.x.x
- ✅ 10.x.x.x
- ✅ 172.16.x.x - 172.31.x.x
- ❌ 不显示公网 IP
- ❌ 不显示 127.0.0.1

### 3. 动态 IP
- IP 地址可能在重启后变化
- 建议每次使用前确认 IP
- 可以在路由器中设置静态 IP

### 4. 防火墙
确保 Windows 防火墙允许端口 8889：
```bash
netsh advfirewall firewall add rule name="ClipSync" dir=in action=allow protocol=TCP localport=8889
```

---

## 🔍 故障排除

### 问题 1: 显示"未找到"
**可能原因**:
- 没有网络连接
- 网络适配器被禁用

**解决方法**:
1. 检查网络连接
2. 启用网络适配器
3. 重启应用

### 问题 2: 显示错误的 IP
**可能原因**:
- 有多个网络接口
- VPN 连接干扰

**解决方法**:
1. 断开不必要的网络连接
2. 关闭 VPN
3. 手动运行 `ipconfig` 确认正确 IP

### 问题 3: 复制按钮无效
**可能原因**:
- IP 地址尚未获取完成

**解决方法**:
1. 等待几秒让 IP 获取完成
2. 确认 IP 不是"获取中..."

---

## 📝 代码位置

### 文件
`packages/windows_app/lib/windows/windows_server.dart`

### 关键部分
1. **变量声明** (第 24 行):
   ```dart
   String _localIP = '获取中...';
   ```

2. **获取方法** (第 48-85 行):
   ```dart
   Future<void> _getLocalIP() async { ... }
   ```

3. **UI 显示** (第 260-290 行):
   ```dart
   Row(
     children: [
       Icon(Icons.wifi, ...),
       Text('局域网 IP: ', ...),
       Text(_localIP, ...),
       IconButton(...),
     ],
   )
   ```

---

## 🚀 未来改进

### 计划功能
1. **多个 IP 显示** - 如果有多个网络接口
2. **IP 刷新按钮** - 手动刷新 IP 地址
3. **QR 码** - 生成二维码供手机扫描
4. **历史记录** - 记录使用过的 IP
5. **自动检测变化** - IP 变化时通知用户

---

## 📞 相关文档

- [QUICKSTART.md](../QUICKSTART.md) - 快速开始指南
- [README.md](../README.md) - 项目说明
- [FLOATING_WINDOW_GUIDE.md](./FLOATING_WINDOW_GUIDE.md) - 悬浮窗功能

---

**功能版本**: v2.3.0  
**添加时间**: 2026-04-24  
**依赖**: dart:io (NetworkInterface)  
