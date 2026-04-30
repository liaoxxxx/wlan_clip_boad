import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clip_sync_common/clip_sync_common.dart';
import 'features/file_manager/file_picker_service.dart';
import 'widgets/file_selector_chip.dart';

/// Android 端：输入捕获 + WebSocket 客户端（支持 WiFi 连接）
class AndroidVoiceClient extends StatelessWidget {
  const AndroidVoiceClient({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi 语音剪贴板',
      theme: ThemeData.dark(),
      home: const _AndroidVoiceClientPage(),
    );
  }
}

class _AndroidVoiceClientPage extends StatefulWidget {
  const _AndroidVoiceClientPage();

  @override
  State<_AndroidVoiceClientPage> createState() => _AndroidVoiceClientPageState();
}

class _AndroidVoiceClientPageState extends State<_AndroidVoiceClientPage> {
  final _controller = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  IOWebSocketChannel? _channel;
  final _debounce = DebounceHelper();
  AppConnectionState _connectionState = AppConnectionState.disconnected;
  Timer? _reconnectTimer;
  int _sendCount = 0;
  
  String _serverHost = AppConstants.defaultWebsocketHost;
  int _serverPort = AppConstants.defaultWebsocketPort;

  final FilePickerService _filePickerService = FilePickerService();
  List<FileMessageModel> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    AppLogger.info('AndroidVoiceClient 初始化...');
    _loadSettings();
  }

  /// 加载保存的设置（不自动连接）
  Future<void> _loadSettings() async {
    AppLogger.info('开始加载设置...');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) {
        AppLogger.info('Widget 未 mounted，取消加载');
        return;
      }
      
      final savedHost = prefs.getString(AppConstants.prefServerHost);
      final savedPort = prefs.getInt(AppConstants.prefServerPort);
      
      AppLogger.info('加载的设置: host=$savedHost, port=$savedPort');
      
      setState(() {
        _serverHost = savedHost ?? AppConstants.defaultWebsocketHost;
        _serverPort = savedPort ?? AppConstants.defaultWebsocketPort;
        _ipController.text = _serverHost;
        _portController.text = _serverPort.toString();
      });
      
      AppLogger.success('设置加载完成: $_serverHost:$_serverPort');
    } catch (e) {
      AppLogger.error('加载设置失败: $e，使用默认值');
      // 如果加载失败，使用默认值
      if (!mounted) return;
      setState(() {
        _serverHost = AppConstants.defaultWebsocketHost;
        _serverPort = AppConstants.defaultWebsocketPort;
        _ipController.text = _serverHost;
        _portController.text = _serverPort.toString();
      });
    }
    // 不再自动连接，等待用户手动点击连接
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefServerHost, _serverHost);
    await prefs.setInt(AppConstants.prefServerPort, _serverPort);
  }

  /// 显示设置对话框
  void _showSettingsDialog() {
    AppLogger.info('点击设置按钮，准备显示对话框...');
    
    if (!mounted) {
      AppLogger.info('Widget 未 mounted，取消显示对话框');
      return;
    }
    
    AppLogger.info('当前 IP: $_serverHost, 端口: $_serverPort');
    
    try {
      showDialog(
        context: context,
        useRootNavigator: true,
        builder: (dialogContext) {
          AppLogger.info('对话框 builder 被调用');
          return AlertDialog(
            title: const Text('服务器设置'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'PC IP 地址',
                      hintText: '例如: 192.168.1.100',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: '端口号',
                      hintText: '例如: 8889',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  AppLogger.info('点击取消');
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('保存'),
                onPressed: () {
                  AppLogger.info('点击保存');
                  setState(() {
                    _serverHost = _ipController.text.trim();
                    _serverPort = int.tryParse(_portController.text.trim()) ?? AppConstants.defaultWebsocketPort;
                  });
                  AppLogger.info('新设置: $_serverHost:$_serverPort');
                  _saveSettings();
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      ).then((_) {
        AppLogger.info('对话框关闭回调');
      }).catchError((error) {
        AppLogger.error('对话框错误: $error');
      });
    } catch (e) {
      AppLogger.error('显示对话框异常: $e');
    }
  }

  Future<void> _connect() async {
    if (_connectionState == AppConnectionState.connecting) return;
    
    // 验证 IP 地址是否为空
    if (_serverHost.trim().isEmpty) {
      AppLogger.error('请先设置 PC IP 地址');
      return;
    }
    
    setState(() => _connectionState = AppConnectionState.connecting);
    AppLogger.connection('正在连接到 $_serverHost:$_serverPort...');

    try {
      _channel = IOWebSocketChannel.connect(
        'ws://$_serverHost:$_serverPort',
      );
      
      _channel!.stream.listen(
        (_) {}, // 客户端无需接收数据
        onDone: () {
          AppLogger.connection('服务器连接已断开');
          if (mounted) {
            setState(() => _connectionState = AppConnectionState.disconnected);
          }
          // 移除自动重连
        },
        onError: (error) {
          AppLogger.error('连接错误: $error');
          if (mounted) {
            setState(() => _connectionState = AppConnectionState.error);
          }
          // 移除自动重连
        },
      );
      
      if (mounted) {
        setState(() => _connectionState = AppConnectionState.connected);
      }
      AppLogger.success('WiFi 通道已建立 ($_serverHost:$_serverPort)');
      
    } catch (e) {
      AppLogger.error('连接失败: $e');
      if (mounted) {
        setState(() => _connectionState = AppConnectionState.error);
      }
      // 移除自动重连
    }
  }

  /// 手动连接/重连
  void _reconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _connect();
  }

  /// 防抖自动发送
  void _onTextChanged(String text) {
    _debounce.cancel();
    
    if (_connectionState != AppConnectionState.connected || text.trim().isEmpty) {
      return;
    }

    _debounce.debounce(
      Duration(milliseconds: AppConstants.debounceDelayMs),
      () {
        final trimmedText = text.trim();
        _channel?.sink.add(trimmedText);
        _sendCount++;
        AppLogger.success('已发送文本 ($_sendCount 次): ${trimmedText.length > 30 ? trimmedText.substring(0, 30) + "..." : trimmedText}');
      },
    );
  }

  /// 手动发送按钮
  void _manualSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) return;
    if (_connectionState != AppConnectionState.connected) return;
    
    // 如果有选中的文件，打包发送
    if (_selectedFiles.isNotEmpty) {
      final filesJson = jsonEncode(_selectedFiles.map((f) => f.toJson()).toList());
      _channel?.sink.add(filesJson);
      AppLogger.success('已发送 ${_selectedFiles.length} 个图片');
      setState(() => _selectedFiles.clear());
    }

    // 发送文本内容
    if (text.isNotEmpty) {
      _channel?.sink.add(text);
      _sendCount++;
      AppLogger.success('手动发送: $text');
    }
  }

  /// 清空输入
  void _clearInput() {
    _controller.clear();
    setState(() => _selectedFiles.clear());
    _debounce.cancel();
  }

  /// 触发文件选择
  Future<void> _pickFile() async {
    final currentCount = _selectedFiles.length;
    if (currentCount >= AppConstants.maxImageSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能选择 ${AppConstants.maxImageSelection} 张图片')),
      );
      return;
    }

    final files = await _filePickerService.pickMultipleImages();
    if (files.isNotEmpty && mounted) {
      setState(() {
        // 确保总数不超过限制
        final remainingSlots = AppConstants.maxImageSelection - _selectedFiles.length;
        final toAdd = files.take(remainingSlots).toList();
        _selectedFiles.addAll(toAdd);
      });
      
      if (files.length > (AppConstants.maxImageSelection - currentCount)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已自动截取前 ${AppConstants.maxImageSelection} 张图片')),
        );
      }
      AppLogger.info('已选择 ${_selectedFiles.length} 个图片');
    }
  }

  String _getStatusText() {
    switch (_connectionState) {
      case AppConnectionState.connected:
        return '✅ WiFi 通道已建立\n📡 服务器: $_serverHost:$_serverPort\n已发送 $_sendCount 次';
      case AppConnectionState.connecting:
        return '🔄 正在连接到 $_serverHost:$_serverPort...';
      case AppConnectionState.error:
        return '❌ 连接失败\n请点击下方按钮重新连接\n当前: $_serverHost:$_serverPort';
      case AppConnectionState.disconnected:
        return '⚪ 未连接\n请点击下方按钮连接到 PC\n当前: $_serverHost:$_serverPort';
    }
  }

  Color _getStatusColor() {
    switch (_connectionState) {
      case AppConnectionState.connected:
        return Colors.green.withOpacity(0.2);
      case AppConnectionState.connecting:
        return Colors.orange.withOpacity(0.2);
      case AppConnectionState.error:
        return Colors.red.withOpacity(0.2);
      case AppConnectionState.disconnected:
        return Colors.grey.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info('build() 被调用，当前状态: $_connectionState');
    return Scaffold(
      resizeToAvoidBottomInset: true, // 防止软键盘弹出时布局溢出
      appBar: AppBar(
        title: const Text('🎤 WiFi 语音剪贴板'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: '服务器设置',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              _connectionState == AppConnectionState.connected 
                ? Icons.wifi 
                : Icons.wifi_off,
              color: _connectionState == AppConnectionState.connected 
                ? Colors.greenAccent 
                : Colors.redAccent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部固定区域：连接状态和按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 连接状态和按钮 - 水平布局
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 连接状态（占据剩余空间）
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: const TextStyle(fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // 连接/断开按钮（固定宽度）
                    SizedBox(
                      width: 120,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          _connectionState == AppConnectionState.connected 
                            ? Icons.link_off 
                            : Icons.wifi,
                          size: 18,
                        ),
                        label: Text(
                          _connectionState == AppConnectionState.connected 
                            ? '断开' 
                            : '连接',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _connectionState == AppConnectionState.connected 
                            ? Colors.redAccent 
                            : Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          AppLogger.info('点击连接/断开按钮，当前状态: $_connectionState');
                          if (_connectionState == AppConnectionState.connected) {
                            // 断开连接
                            AppLogger.info('执行断开连接操作');
                            _channel?.sink.close();
                            setState(() => _connectionState = AppConnectionState.disconnected);
                            AppLogger.connection('已手动断开连接');
                          } else {
                            // 连接
                            AppLogger.info('执行连接操作，目标: $_serverHost:$_serverPort');
                            _reconnect();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 中间可扩展区域：文本输入框
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // 图片选择状态展示
                  if (_selectedFiles.isNotEmpty)
                    SelectedImagePreview(
                      files: _selectedFiles,
                      onRemove: (file) => setState(() => _selectedFiles.remove(file)),
                    ),
                  // 文本输入框 - 自动填充剩余高度
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null, // 无限行数
                      expands: true, // 自动扩展填充父容器
                      textAlignVertical: TextAlignVertical.top, // 文本从顶部开始
                      decoration: InputDecoration(
                        hintText: '🎤 在此点击使用语音输入...\n\n支持多行文本输入，内容会自动滚动',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _manualSend,
                              tooltip: '手动发送',
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearInput,
                              tooltip: '清空',
                              iconSize: 20,
                            ),
                            IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _pickFile,
                              tooltip: '添加文件/图片',
                            ),
                          ],
                        ),
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部固定区域：使用步骤和提示信息（两列布局）
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左列：使用步骤
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      title: const Text(
                        '📝 使用步骤',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      collapsedBackgroundColor: Colors.blueGrey.withOpacity(0.2),
                      backgroundColor: Colors.blueGrey.withOpacity(0.3),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('1. 点击右上角 ⚙️ 设置 PC IP 地址', style: TextStyle(fontSize: 11)),
                              SizedBox(height: 4),
                              Text('2. 点击「连接到 PC」按钮建立连接', style: TextStyle(fontSize: 11)),
                              SizedBox(height: 4),
                              Text('3. 点击下方输入框唤起键盘', style: TextStyle(fontSize: 11)),
                              SizedBox(height: 4),
                              Text('4. 使用麦克风语音输入', style: TextStyle(fontSize: 11)),
                              SizedBox(height: 4),
                              Text('5. 识别完成后自动同步至 PC 剪贴板', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 右列：提示信息
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      title: const Text(
                        '💡 提示',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      collapsedBackgroundColor: Colors.black26,
                      backgroundColor: Colors.black26,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• 确保手机和 PC 在同一局域网（同一 WiFi）', style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 4),
                              const Text('• 在 Windows 端查看本机 IP 地址', style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 4),
                              const Text('• 支持 Gboard、搜狗、微信等输入法语音输入', style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 4),
                              const Text('• 停止输入 0.5 秒后自动发送', style: TextStyle(fontSize: 11)),
                              const SizedBox(height: 8),
                              Text(
                                '📡 WiFi 无线版 - 无需 USB 线，自由连接',
                                style: TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce.dispose();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
