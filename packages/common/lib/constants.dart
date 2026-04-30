/// 共享常量配置
class AppConstants {
  // WebSocket 配置
  static const int defaultWebsocketPort = 8889;
  static const String defaultWebsocketHost = '192.168.1.100'; // 默认 PC IP，可在 Android 端修改
  
  // SharedPreferences 键名
  static const String prefServerHost = 'server_host';
  static const String prefServerPort = 'server_port';
  
  // ADB 端口转发命令（仅 USB 模式使用）
  static String get adbForwardCommand => 'adb forward tcp:$defaultWebsocketPort tcp:$defaultWebsocketPort';
  
  // 防抖延迟（毫秒）
  static const int debounceDelayMs = 500;
  
  // 重连间隔（秒）
  static const int reconnectIntervalSec = 3;

  // 图片选择限制
  static const int maxImageSelection = 9;
}

/// 应用连接状态枚举（避免与 Flutter 内置 ConnectionState 冲突）
enum AppConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// 消息类型
enum MessageType {
  text,
  command,
  file,
  image,
}
