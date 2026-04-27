import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';

/// 系统托盘管理器
class TrayManager {
  static final TrayManager _instance = TrayManager._internal();
  factory TrayManager() => _instance;
  TrayManager._internal();

  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();
  
  bool _isInitialized = false;
  VoidCallback? onShowWindow;
  VoidCallback? onHideWindow;
  VoidCallback? onExit;

  /// 初始化系统托盘
  Future<void> initTray({
    required String title,
    required String tooltip,
    required VoidCallback onShowWindow,
    required VoidCallback onHideWindow,
    required VoidCallback onExit,
  }) async {
    if (!Platform.isWindows) {
      print('系统托盘仅在 Windows 平台可用');
      return;
    }

    this.onShowWindow = onShowWindow;
    this.onHideWindow = onHideWindow;
    this.onExit = onExit;

    try {
      // 初始化系统托盘
      await _systemTray.initSystemTray(
        iconPath: _getIconPath(),
        title: title,
      );

      // 设置托盘提示文本
      await _systemTray.setToolTip(tooltip);

      // 构建托盘菜单
      await _buildMenu();

      // 设置上下文菜单
      await _systemTray.setContextMenu(_menu);

      // 监听托盘点击事件
      _systemTray.registerSystemTrayEventHandler((String eventName) {
        print('托盘事件: $eventName');
        if (eventName == kSystemTrayEventClick) {
          // 左键点击：显示窗口
          onShowWindow?.call();
        } else if (eventName == kSystemTrayEventRightClick) {
          // 右键点击：弹出菜单（Windows 上自动处理）
          if (!Platform.isWindows) {
            _systemTray.popUpContextMenu();
          }
        }
      });

      _isInitialized = true;
      print('✅ 系统托盘初始化成功');
    } catch (e) {
      print('⚠️ 系统托盘初始化失败: $e');
      print('💡 提示：请确保 assets/icons/tray_icon.ico 文件存在，或使用默认图标');
      // 即使初始化失败，应用仍可正常运行
    }
  }

  /// 构建托盘菜单
  Future<void> _buildMenu() async {
    await _menu.buildFrom([
      MenuItemLabel(
        label: '显示窗口',
        onClicked: (menuItem) {
          onShowWindow?.call();
        },
      ),
      MenuItemLabel(
        label: '隐藏窗口',
        onClicked: (menuItem) {
          onHideWindow?.call();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: '退出',
        onClicked: (menuItem) {
          onExit?.call();
        },
      ),
    ]);
  }

  /// 获取图标路径
  String _getIconPath() {
    // 尝试使用应用图标，如果没有则使用系统默认图标
    // 注意：在实际部署时，应该将 tray_icon.ico 放在 assets/icons/ 目录下
    // 并在 pubspec.yaml 中声明 assets
    const String iconPath = 'assets/icons/tray_icon.ico';
    
    // 检查文件是否存在（在开发环境中）
    final file = File(iconPath);
    if (file.existsSync()) {
      return iconPath;
    }
    
    // 如果图标文件不存在，返回空字符串，system_tray 会使用默认图标
    print('⚠️ 未找到托盘图标文件: $iconPath，将使用默认图标');
    return '';
  }

  /// 更新托盘提示文本
  Future<void> updateTooltip(String tooltip) async {
    if (_isInitialized) {
      await _systemTray.setToolTip(tooltip);
    }
  }

  /// 销毁托盘
  Future<void> dispose() async {
    if (_isInitialized) {
      await _systemTray.destroy();
      _isInitialized = false;
    }
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
}
