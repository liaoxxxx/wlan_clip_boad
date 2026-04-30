import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../image_preview/image_message_model.dart';
import '../image_preview/image_preview_widget.dart';

/// 媒体管理 Tab 组件：整合文件列表与图片预览
class MediaManagerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> receivedFiles;
  final List<ImageMessageModel> receivedImages;
  final Function(Map<String, dynamic>) onSaveFile;

  const MediaManagerWidget({
    super.key,
    required this.receivedFiles,
    required this.receivedImages,
    required this.onSaveFile,
  });

  @override
  State<MediaManagerWidget> createState() => _MediaManagerWidgetState();
}

class _MediaManagerWidgetState extends State<MediaManagerWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.cyan,
          tabs: const [
            Tab(text: '📁 文件管理'),
            Tab(text: '🖼️ 图片预览'),
          ],
        ),
        SizedBox(
          height: 350, // 增加高度以容纳 TabBar 和内容
          child: TabBarView(
            controller: _tabController,
            // 关键优化：使用 Key 确保 TabBarView 的子组件在数据更新时不会被错误重建
            children: [
              // Tab 1: 文件管理 - 使用 ValueKey 稳定组件
              KeyedSubtree(
                key: const ValueKey('file_list_tab'),
                child: _buildFileList(),
              ),
              // Tab 2: 图片预览 - 使用 ValueKey 稳定组件
              KeyedSubtree(
                key: const ValueKey('image_grid_tab'),
                child: _buildImageGrid(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileList() {
    if (widget.receivedFiles.isEmpty) {
      return const Center(
        child: Text('暂无接收的文件', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: widget.receivedFiles.length,
      itemBuilder: (context, index) {
        final file = widget.receivedFiles[index];
        return ListTile(
          leading: const Icon(Icons.insert_drive_file, color: Colors.cyan),
          title: Text(file['name'], style: const TextStyle(fontSize: 13)),
          subtitle: Text(
            '${_formatFileSize(file['size'])} · ${file['status']}',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.save_alt, size: 18),
            tooltip: '保存文件',
            onPressed: () => widget.onSaveFile(file),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid() {
    if (widget.receivedImages.isEmpty) {
      return const Center(
        child: Text('暂无接收的图片', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.receivedImages.length,
      itemBuilder: (context, index) {
        final img = widget.receivedImages[index];
        try {
          final bytes = base64Decode(img.base64Data);
          // 关键优化：为每个图片组件添加唯一的 ValueKey，确保 Flutter 能正确复用组件
          return ImagePreviewWidget(
            key: ValueKey('img_${img.name}_${img.size}'),
            imageData: bytes,
            fileName: img.name,
          );
        } catch (e) {
          return Card(
            key: ValueKey('img_error_${img.name}'),
            child: Center(
              child: Text('解码失败\n${img.name}', 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
          );
        }
      },
    );
  }
}
