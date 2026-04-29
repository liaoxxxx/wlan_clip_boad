import 'package:flutter/material.dart';
import '../features/file_manager/file_picker_service.dart';

/// 文件选择状态展示组件
class FileSelectorChip extends StatelessWidget {
  final FileMessageModel file;
  final VoidCallback onRemove;

  const FileSelectorChip({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Chip(
        label: Text(
          '${file.name} (${_formatSize(file.size)})',
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
        onDeleted: onRemove,
        backgroundColor: Colors.teal.withOpacity(0.8),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

