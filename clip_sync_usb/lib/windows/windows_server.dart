import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import '../common/constants.dart';
import '../common/utils.dart';
import 'clipboard_helper.dart';

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
  
  // 输入模式：true=直接输入到焦点窗口，false=仅写入剪贴板
  bool _autoTypeMode = false;
  bool _usePasteMethod = true; // 使用粘贴方式（Ctrl+V）而非逐字符输入

  @override
  void initState() {
    super.initState();
    _startServer();
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
          AppLogger.info('收到文本: ${text.length > 50 ? text.substring(0, 50) + "..." : text}');
          
          if (_autoTypeMode) {
            // 自动输入模式：直接输入到当前焦点窗口
            await _autoTypeText(text);
            _addLog('⌨️ 已输入: ${text.length > 30 ? text.substring(0, 30) + "..." : text}');
            AppLogger.success('已自动输入 (${text.length} 字符)');
          } else {
            // 剪贴板模式：仅写入剪贴板
            await _setClipboard(text);
            _addLog('📋 已同步: ${text.length > 30 ? text.substring(0, 30) + "..." : text}');
            AppLogger.success('已写入剪贴板 (${text.length} 字符)');
          }
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
    // 仅在 Windows 平台执行
    if (!Platform.isWindows) {
      AppLogger.warning('自动输入功能仅在 Windows 平台可用');
      return;
    }
    
    try {
      // 延迟加载键盘输入模块
      await keyboard.loadLibrary();
      
      if (_usePasteMethod) {
        await keyboard.pasteText(text);
      } else {
        await keyboard.sendKeys(text);
      }
    } catch (e) {
      AppLogger.error('自动输入失败: $e');
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态卡片
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🖥️ 服务器状态',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 输入模式选择
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⌨️ 输入模式设置',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('自动输入模式', style: TextStyle(fontSize: 13)),
                      subtitle: Text(
                        _autoTypeMode 
                            ? '收到文本后直接输入到当前焦点窗口'
                            : '收到文本后仅写入剪贴板',
                        style: const TextStyle(fontSize: 11),
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
                    if (_autoTypeMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: SwitchListTile(
                          title: const Text('使用粘贴方式 (Ctrl+V)', style: TextStyle(fontSize: 12)),
                          subtitle: const Text('更快，适合长文本', style: TextStyle(fontSize: 10)),
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
              const SizedBox(height: 16),
              
              // 使用说明
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 使用说明:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('1. 查看本机 IP: 运行 ipconfig (IPv4 地址)'),
                    Text('2. 在 Android 端设置此 IP 地址'),
                    Text('3. 确保手机和 PC 在同一 WiFi 网络'),
                    Text('4. 启动 Android 客户端并连接'),
                    Text('5. 选择输入模式：剪贴板 或 自动输入'),
                    Text('6. 如使用自动输入，请将光标放在目标输入框'),
                    Text('7. 保持此窗口最小化运行即可'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 日志区域
              const Text(
                '📜 连接日志:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
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
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Consolas',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }
}
