import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Windows 平台只需要导入 Windows 服务器
import 'windows/windows_server.dart';

void main() {
  // Windows 平台直接启动服务器
  runApp(const WindowsClipboardServer());
  
  // 配置窗口行为（仅 Windows）
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      // 设置窗口最小尺寸
      appWindow.minSize = const Size(380, 600);
      // 初始显示窗口
      appWindow.show();
    });
  }
}
