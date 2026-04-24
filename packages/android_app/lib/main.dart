import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Android 平台只需要导入 Android 客户端
import 'android_client.dart';

void main() {
  // Android 平台直接启动客户端
  runApp(const AndroidVoiceClient());
}
