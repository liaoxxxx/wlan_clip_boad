import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../windows/clipboard_helper.dart';

/// 图片预览组件
/// 使用 StatefulWidget + AutomaticKeepAliveClientMixin 保持状态，避免闪烁
class ImagePreviewWidget extends StatefulWidget {
  final Uint8List imageData;
  final String fileName;

  const ImagePreviewWidget({
    super.key,
    required this.imageData,
    required this.fileName,
  });

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持组件状态，避免 Tab 切换时重建

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 AutomaticKeepAliveClientMixin
    
    // 使用 LayoutBuilder 获取容器实际尺寸，实现响应式布局
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // 定义最小显示阈值
        const double minWidthThreshold = 100.0;
        const double minHeightThreshold = 80.0;
        
        // 判断是否使用紧凑模式
        final bool isCompactMode = width < minWidthThreshold || height < minHeightThreshold;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: isCompactMode 
            ? _buildCompactView(context) 
            : _buildNormalView(context),
        );
      },
    );
  }

  /// 紧凑模式：仅显示图标和文件名
  Widget _buildCompactView(BuildContext context) {
    return InkWell(
      onTap: () => _showFullScreen(context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标 - 固定大小
            Icon(Icons.image, size: 28, color: Colors.cyan),
            const SizedBox(height: 2),
            // 文件名 - 限制为 1 行，避免溢出
            Text(
              widget.fileName,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // 按钮区域 - 使用固定高度约束
            SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 14),
                    tooltip: '复制图片',
                    onPressed: () => _copyImageToClipboard(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_alt, size: 14),
                    tooltip: '保存图片',
                    onPressed: () => _saveImage(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, size: 14),
                    tooltip: '放大查看',
                    onPressed: () => _showFullScreen(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 正常模式：完整显示图片预览
  Widget _buildNormalView(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算图片区域的可用高度：总高度 - 顶部区域（Padding + Row）
        // 顶部区域约 60px (Padding 16 + Row ~44)，预留额外 10px 余量
        final availableHeight = constraints.maxHeight - 70.0;
        final imageHeight = availableHeight.clamp(60.0, 200.0); // 最小 60px，最大 200px
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: '复制图片',
                    onPressed: () => _copyImageToClipboard(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_alt, size: 18),
                    tooltip: '保存图片',
                    onPressed: () => _saveImage(context),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showFullScreen(context),
              child: Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.memory(
                    widget.imageData,
                    fit: BoxFit.contain,
                    gaplessPlayback: true, // 关键：图片加载时保持旧图显示，避免闪烁
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('图片加载失败', style: TextStyle(color: Colors.red)));
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: InteractiveViewer(
            child: Image.memory(widget.imageData),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) return;
      
      final filePath = '${directory.path}/${widget.fileName}';
      final file = File(filePath);
      await file.writeAsBytes(widget.imageData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已保存到: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败'), backgroundColor: Colors.red),
      );
    }
  }

  /// 复制图片到剪贴板
  Future<void> _copyImageToClipboard(BuildContext context) async {
    try {
      // 显示加载提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('正在处理图片...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // 尝试使用 WindowsClipboardHelper 复制图片
      final success = await WindowsClipboardHelper.setImageToClipboard(widget.imageData);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 图片已复制到剪贴板'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 如果直接复制失败，提供备用方案：保存到临时目录并提示用户
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/${widget.fileName}';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(widget.imageData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ 直接复制功能暂不可用'),
                const SizedBox(height: 4),
                Text(
                  '图片已保存到临时目录：\n$tempPath',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '打开文件夹',
              textColor: Colors.white,
              onPressed: () {
                // TODO: 可以调用 Process.run 打开文件管理器
                print('打开文件夹: ${tempDir.path}');
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 复制失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
