import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clip_sync_common/clip_sync_common.dart';
import 'package:win32/win32.dart' as win32;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'clipboard_helper.dart';
import 'tray_manager.dart';

// 延迟加载 Windows 专用的键盘输入模块
import 'keyboard_input_helper.dart' deferred as keyboard;

/// Windows 端：WebSocket 服务 + 剪贴板写入
class WindowsClipboardServer extends StatefulWidget {
  const WindowsClipboardServer({super.key});

  @override
  State<WindowsClipboardServer> createState() => _WindowsClipboardServerState();
}

class _WindowsClipboardServerState extends State<WindowsClipboardServer> {
  String _status = '🔄 正在启动服务...';
  HttpServer? _server;
  int _clientCount = 0;
  final List<String> _logs = [];
  String _localIP = '获取中...'; // 本机 IP 地址
  
  // 输入模式：true=直接输入到焦点窗口，false=仅写入剪贴板
  bool _autoTypeMode = true; // 默认开启自动输入模式
  bool _usePasteMethod = true; // 使用粘贴方式（Ctrl+V）而非逐字符输入
  bool _alwaysOnTop = false; // 悬浮窗模式（置顶）
  
  // 模块折叠状态
  bool _serverStatusExpanded = false; // 服务器状态 - 默认折叠
  bool _textInputExpanded = true; // 接收的文本 - 默认展开
  bool _inputModeExpanded = false; // 输入模式 - 默认折叠
  bool _windowSettingsExpanded = false; // 窗口设置 - 默认折叠
  bool _instructionsExpanded = false; // 使用说明 - 默认折叠
  bool _logsExpanded = false; // 连接日志 - 默认折叠
  
  // 最近接收的文本
  String _lastReceivedText = '';
  
  // 系统托盘管理器
  final TrayManager _trayManager = TrayManager();
  bool _isWindowHidden = false; // 窗口是否隐藏到托盘
  
  // 窗口高度自适应
  double _windowHeight = 700.0; // 当前窗口高度
  static const double _compactThreshold = 450.0; // 紧凑模式阈值
  static const double _minimalThreshold = 300.0; // 最小模式阈值
  static const double _minWindowHeight = 200.0; // 最小窗口高度
  Timer? _windowSizeTimer; // 窗口尺寸监听定时器

  @override
  void initState() {
    super.initState();
    _getLocalIP();
    _startServer();
    _initTray();
    _initWindowHeightListener();
  }

  /// 初始化窗口高度监听
  void _initWindowHeightListener() {
    // 延迟一点时间等待窗口创建完成
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _updateWindowHeight();
        // 启动定时器，每 200ms 检查一次窗口尺寸
        _windowSizeTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          if (mounted) {
            _updateWindowHeight();
          }
        });
      }
    });
  }

  /// 更新窗口高度
  void _updateWindowHeight() {
    if (Platform.isWindows) {
      try {
        final size = appWindow.size;
        setState(() {
          _windowHeight = size.height;
        });
      } catch (e) {
        AppLogger.warning('获取窗口高度失败: $e');
      }
    }
  }

  /// 判断是否为紧凑模式（隐藏部分组件）
  bool get _isCompactMode => _windowHeight < _compactThreshold;

  /// 判断是否为最小模式（只显示文本区域）
  bool get _isMinimalMode => _windowHeight < _minimalThreshold;

  /// 获取本机局域网 IP 地址
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
              AppLogger.info('本机 IP: $_localIP');
              return;
            }
          }
        }
      }
      
      // 如果没有找到，显示提示
      setState(() {
        _localIP = '未找到';
      });
    } catch (e) {
      setState(() {
        _localIP = '获取失败';
      });
      AppLogger.warning('获取 IP 地址失败: $e');
    }
  }

  /// 初始化系统托盘
  Future<void> _initTray() async {
    if (Platform.isWindows) {
      await _trayManager.initTray(
        title: 'ClipSync WiFi',
        tooltip: 'ClipSync WiFi - 剪贴板同步服务',
        onShowWindow: _showWindow,
        onHideWindow: _hideWindow,
        onExit: _exitApp,
      );
    }
  }

  /// 显示窗口
  void _showWindow() {
    if (_isWindowHidden) {
      appWindow.show();
      setState(() {
        _isWindowHidden = false;
      });
      _addLog('📱 窗口已显示');
    }
  }

  /// 隐藏窗口到托盘
  void _hideWindow() {
    if (!_isWindowHidden) {
      appWindow.hide();
      setState(() {
        _isWindowHidden = true;
      });
      _addLog('📴 窗口已隐藏到托盘');
    }
  }

  /// 退出应用
  void _exitApp() {
    _addLog('👋 应用正在退出...');
    _trayManager.dispose();
    _server?.close();
    exit(0);
  }

  /// 设置窗口置顶
  void _setAlwaysOnTop(bool onTop) {
    if (Platform.isWindows) {
      try {
        // 使用 Win32 API 设置窗口置顶
        final hwnd = win32.GetForegroundWindow();
        if (hwnd != 0) {
          final hWndInsertAfter = onTop 
              ? win32.HWND_TOPMOST 
              : win32.HWND_NOTOPMOST;
          win32.SetWindowPos(
            hwnd,
            hWndInsertAfter,
            0, 0, 0, 0,
            win32.SWP_NOMOVE | win32.SWP_NOSIZE,
          );
          AppLogger.info(onTop ? '已启用悬浮窗模式' : '已禁用悬浮窗模式');
        }
      } catch (e) {
        AppLogger.warning('设置窗口置顶失败: $e');
      }
    }
  }

  /// 可折叠卡片组件
  Widget _buildCollapsibleCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    Color? headerColor,
    Color? borderColor,
    bool alwaysVisible = false, // 是否始终可见（不受最小模式影响）
  }) {
    if (_isMinimalMode && !alwaysVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: headerColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏 - 可点击
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: borderColor ?? Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          // 内容区域 - 展开时显示
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
        ],
      ),
    );
  }

  Future<void> _startServer() async {
    try {
      AppLogger.info('正在启动 WebSocket 服务器...');
      
      // 监听所有网络接口，支持 WiFi 连接
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4, 
        AppConstants.defaultWebsocketPort,
      );
      
      final address = _server!.address.address == '0.0.0.0' ? '0.0.0.0' : _server!.address.address;
      
      _addLog('✅ 服务已启动');
      _addLog('监听: $address:${AppConstants.defaultWebsocketPort} (WiFi模式)');
      _addLog('等待 Android 连接...');
      
      setState(() {
        _status = '✅ 服务运行中\n端口: ${AppConstants.defaultWebsocketPort}\n模式: WiFi 无线连接';
      });
      
      AppLogger.success('WebSocket 服务器已启动，监听端口 ${AppConstants.defaultWebsocketPort}');
      
      _server!.listen(_handleConnection);
    } catch (e) {
      final errorMsg = '❌ 启动失败: $e\n请检查端口 ${AppConstants.defaultWebsocketPort} 是否被占用';
      _addLog(errorMsg);
      setState(() => _status = errorMsg);
      AppLogger.error('服务器启动失败: $e');
    }
  }

  void _handleConnection(HttpRequest req) async {
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      final socket = await WebSocketTransformer.upgrade(req);
      _clientCount++;
      
      AppLogger.connection('Android 客户端已连接 (#$_clientCount)');
      _addLog('📱 客户端连接 #$_clientCount');
      
      socket.listen(
        (data) async {
          final text = data.toString();
          
          // 详细日志：接收文本
          AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          AppLogger.info('📨 收到文本 (${text.length} 字符)');
          if (text.length > 100) {
            AppLogger.info('   内容: ${text.substring(0, 100)}...');
          } else {
            AppLogger.info('   内容: $text');
          }
          AppLogger.info('⚙️ 当前状态: _autoTypeMode=$_autoTypeMode, _usePasteMethod=$_usePasteMethod');
          
          // 更新最后接收的文本（用于显示）
          setState(() {
            _lastReceivedText = text;
          });
          
          if (_autoTypeMode) {
            // 自动输入模式：直接输入到当前焦点窗口
            AppLogger.info('🔄 开始自动输入流程...');
            await _autoTypeText(text);
            AppLogger.success('✅ 自动输入完成');
            _addLog('⌨️ 已输入: ${text.length > 30 ? text.substring(0, 30) + "..." : text}');
          } else {
            // 剪贴板模式：仅写入剪贴板
            AppLogger.info('📋 使用剪贴板模式');
            await _setClipboard(text);
            AppLogger.success('✅ 已写入剪贴板');
            _addLog('📋 已同步: ${text.length > 30 ? text.substring(0, 30) + "..." : text}');
          }
          AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        },
        onError: (e) {
          AppLogger.error('连接异常: $e');
          _addLog('⚠️ 连接错误: $e');
        },
        onDone: () {
          AppLogger.connection('Android 客户端已断开');
          _addLog('📴 客户端断开');
        },
      );
    } else {
      req.response.statusCode = 404;
      req.response.close();
    }
  }

  /// 使用 Win32 API 直接写入剪贴板（不受窗口焦点/前台限制）
  Future<void> _setClipboard(String text) async {
    await WindowsClipboardHelper.setClipboard(text);
  }

  /// 自动输入文本到当前焦点窗口
  Future<void> _autoTypeText(String text) async {
    AppLogger.info('🔍 [自动输入] 开始处理...');
    
    // 仅在 Windows 平台执行
    if (!Platform.isWindows) {
      AppLogger.warning('⚠️ [自动输入] 非 Windows 平台，跳过');
      return;
    }
    
    AppLogger.info('🔍 [自动输入] 平台检查通过 (Windows)');
    AppLogger.info('🔍 [自动输入] 文本长度: ${text.length} 字符');
    AppLogger.info('🔍 [自动输入] 使用方式: ${_usePasteMethod ? "粘贴 (Ctrl+V)" : "逐字符输入"}');
    
    try {
      // 延迟加载键盘输入模块
      AppLogger.info('📦 [自动输入] 正在加载 keyboard_input_helper...');
      await keyboard.loadLibrary();
      AppLogger.success('✅ [自动输入] 库加载成功');
      
      if (_usePasteMethod) {
        AppLogger.info('📋 [自动输入] 调用 pasteText()...');
        await keyboard.pasteText(text);
        AppLogger.success('✅ [自动输入] pasteText() 执行完成');
      } else {
        AppLogger.info('⌨️ [自动输入] 调用 sendKeys()...');
        await keyboard.sendKeys(text);
        AppLogger.success('✅ [自动输入] sendKeys() 执行完成');
      }
      
      AppLogger.success('🎉 [自动输入] 全部流程完成');
    } catch (e, stackTrace) {
      AppLogger.error('❌ [自动输入] 失败: $e');
      AppLogger.error('📍 [自动输入] 堆栈跟踪:\n$stackTrace');
      rethrow;
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${_getTimeString()} $message');
      if (_logs.length > 50) {
        _logs.removeAt(0);
      }
    });
  }

  String _getTimeString() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 配置 bitsdojo_window
    doWhenWindowReady(() {
      if (Platform.isWindows) {
        // 设置窗口标题
        appWindow.title = 'ClipSync WiFi - 剪贴板同步服务';
        // 设置最小窗口尺寸
        appWindow.minSize = const Size(380, 200);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // 拦截返回键/关闭按钮，改为隐藏到托盘
        _hideWindow();
        return false; // 阻止默认关闭行为
      },
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        // 根据模式决定是否显示 AppBar
        appBar: _isMinimalMode ? null : AppBar(
          title: const Text('💻 Windows 剪贴板服务器'),
          backgroundColor: Colors.blueGrey,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.usb, color: Colors.greenAccent),
                  const SizedBox(width: 4),
                  Text('$_clientCount', style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        body: Padding(
          padding: _isMinimalMode ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务器状态 - 可折叠
              if (!_isMinimalMode)
                _buildCollapsibleCard(
                  title: '🖥️ 服务器状态',
                  isExpanded: _serverStatusExpanded,
                  onToggle: () {
                    setState(() {
                      _serverStatusExpanded = !_serverStatusExpanded;
                    });
                  },
                  borderColor: Colors.greenAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_status, style: const TextStyle(fontSize: 12)),
                      if (!_isCompactMode) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.wifi, size: 16, color: Colors.greenAccent),
                            const SizedBox(width: 4),
                            const Text(
                              '局域网 IP: ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                _localIP,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Consolas',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              tooltip: '复制 IP 地址',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (_localIP != '获取中...' && _localIP != '未找到') {
                                  _setClipboard(_localIP);
                                  _addLog('📋 已复制 IP 地址: $_localIP');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              if (!_isMinimalMode) const SizedBox(height: 8),
              
              // 实时文本显示区域 - 始终显示，核心组件（可折叠但默认展开）
              Flexible(
                flex: _isMinimalMode ? 1 : 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题栏 - 可点击折叠
                      InkWell(
                        onTap: () {
                          setState(() {
                            _textInputExpanded = !_textInputExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isMinimalMode ? '📝' : '📝 接收的文本',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: _isMinimalMode ? 12 : 14
                              ),
                            ),
                            if (!_isMinimalMode)
                              Row(
                                children: [
                                  if (_lastReceivedText.isNotEmpty)
                                    TextButton.icon(
                                      icon: const Icon(Icons.copy, size: 16),
                                      label: const Text('复制', style: TextStyle(fontSize: 12)),
                                      onPressed: () {
                                        _setClipboard(_lastReceivedText);
                                        _addLog('📋 已复制到最后接收的文本');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                        minimumSize: Size.zero,
                                      ),
                                    ),
                                  Icon(
                                    _textInputExpanded ? Icons.expand_less : Icons.expand_more,
                                    size: 20,
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // 内容区域 - 展开时显示
                      if (_textInputExpanded) ...[
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _lastReceivedText.isEmpty 
                                    ? '等待接收文本...'
                                    : _lastReceivedText,
                                style: TextStyle(
                                  fontSize: _isMinimalMode ? 12 : 13,
                                  fontFamily: 'Consolas',
                                  color: _lastReceivedText.isEmpty ? Colors.grey : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!_isMinimalMode) const SizedBox(height: 8),
              
              // 输入模式选择 - 可折叠
              if (!_isMinimalMode)
                _buildCollapsibleCard(
                  title: '⌨️ 输入模式',
                  isExpanded: _inputModeExpanded,
                  onToggle: () {
                    setState(() {
                      _inputModeExpanded = !_inputModeExpanded;
                    });
                  },
                  headerColor: Colors.orange,
                  borderColor: Colors.orange,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('自动输入模式', style: TextStyle(fontSize: 12)),
                        subtitle: Text(
                          _autoTypeMode 
                              ? '收到文本后直接输入到当前焦点窗口'
                              : '收到文本后仅写入剪贴板',
                          style: const TextStyle(fontSize: 10),
                        ),
                        value: _autoTypeMode,
                        onChanged: (value) {
                          setState(() {
                            _autoTypeMode = value;
                          });
                          _addLog(value ? '✅ 已启用自动输入模式' : '📋 已切换到剪贴板模式');
                        },
                        activeColor: Colors.orange,
                      ),
                      if (_autoTypeMode && !_isCompactMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('使用粘贴方式 (Ctrl+V)', style: TextStyle(fontSize: 11)),
                            subtitle: const Text('更快，适合长文本', style: TextStyle(fontSize: 9)),
                            value: _usePasteMethod,
                            onChanged: (value) {
                              setState(() {
                                _usePasteMethod = value;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              
              // 悬浮窗模式（置顶）- 可折叠
              if (!_isMinimalMode)
                _buildCollapsibleCard(
                  title: '📌 窗口设置',
                  isExpanded: _windowSettingsExpanded,
                  onToggle: () {
                    setState(() {
                      _windowSettingsExpanded = !_windowSettingsExpanded;
                    });
                  },
                  headerColor: Colors.purple,
                  borderColor: Colors.purple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('悬浮窗模式', style: TextStyle(fontSize: 12)),
                        subtitle: const Text('窗口始终保持在最前面', style: TextStyle(fontSize: 10)),
                        value: _alwaysOnTop,
                        onChanged: (value) {
                          setState(() {
                            _alwaysOnTop = value;
                          });
                          _setAlwaysOnTop(value);
                          _addLog(value ? '📌 已启用悬浮窗模式' : '📌 已禁用悬浮窗模式');
                        },
                        activeColor: Colors.purple,
                      ),
                    ],
                  ),
                ),
              
              // 使用说明（简化版）- 可折叠
              if (!_isCompactMode && !_isMinimalMode)
                _buildCollapsibleCard(
                  title: '💡 使用说明',
                  isExpanded: _instructionsExpanded,
                  onToggle: () {
                    setState(() {
                      _instructionsExpanded = !_instructionsExpanded;
                    });
                  },
                  headerColor: Colors.green,
                  borderColor: Colors.green,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('• 自动输入模式已默认开启', style: TextStyle(fontSize: 10)),
                      SizedBox(height: 2),
                      Text('• 将光标放在目标输入框即可自动输入', style: TextStyle(fontSize: 10)),
                      SizedBox(height: 2),
                      Text('• 接收的文本会实时显示在上方', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              if (!_isMinimalMode) const SizedBox(height: 8),
              
              // 日志区域 - 可折叠
              if (!_isMinimalMode)
                _buildCollapsibleCard(
                  title: '📜 连接日志',
                  isExpanded: _logsExpanded,
                  onToggle: () {
                    setState(() {
                      _logsExpanded = !_logsExpanded;
                    });
                  },
                  headerColor: Colors.grey,
                  borderColor: Colors.grey,
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text(
                                '等待连接...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    _logs[index],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Consolas',
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ), // WillPopScope
    );
  }

  @override
  void dispose() {
    _windowSizeTimer?.cancel();
    _trayManager.dispose();
    _server?.close();
    super.dispose();
  }
}
