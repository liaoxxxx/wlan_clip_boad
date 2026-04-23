// Windows Server Stub - 用于非 Windows 平台
// 当在 Android/iOS 等平台构建时使用此 stub

import 'package:flutter/material.dart';

/// Windows 剪贴板服务器 - Stub 实现
class WindowsClipboardServer extends StatelessWidget {
  const WindowsClipboardServer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Windows Only'),
        ),
        body: const Center(
          child: Text(
            '此功能仅在 Windows 平台可用',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
