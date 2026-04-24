import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Windows 平台只需要导入 Windows 服务器
import 'windows/windows_server.dart';

void main() {
  // Windows 平台直接启动服务器
  runApp(const WindowsClipboardServer());
}
