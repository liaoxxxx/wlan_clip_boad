import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 平台特定模块导入
// 注意：windows_server.dart 包含 Windows 专用代码（win32 API）
// 在 Android 平台构建时，虽然会编译此文件，但不会运行
import 'windows/windows_server.dart';
import 'android/android_client.dart';

void main() {
  // 自动识别平台启动对应逻辑
  if (Platform.isWindows) {
    runApp(const WindowsClipboardServer());
  } else if (Platform.isAndroid) {
    runApp(const AndroidVoiceClient());
  } else {
    runApp(const UnsupportedPlatformApp());
  }
}

/// 不支持的平台提示
class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '❌ 不支持的平台',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '当前平台: ${Platform.operatingSystem}\n'
                '仅支持 Windows 和 Android',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
