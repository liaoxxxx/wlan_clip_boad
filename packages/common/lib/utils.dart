import 'dart:async';
import 'package:flutter/foundation.dart';

/// 防抖工具类 - 用于避免频繁发送消息
class DebounceHelper {
  Timer? _timer;
  
  /// 执行防抖操作
  void debounce(Duration delay, VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
  
  /// 取消当前的防抖定时器
  void cancel() {
    _timer?.cancel();
  }
  
  /// 释放资源
  void dispose() {
    cancel();
  }
}

/// 日志工具类
class AppLogger {
  static void info(String message) {
    debugPrint('📋 [INFO] $message');
  }
  
  static void success(String message) {
    debugPrint('✅ [SUCCESS] $message');
  }
  
  static void error(String message) {
    debugPrint('❌ [ERROR] $message');
  }
  
  static void warning(String message) {
    debugPrint('⚠️ [WARNING] $message');
  }
  
  static void connection(String message) {
    debugPrint('🔌 [CONNECTION] $message');
  }
}
