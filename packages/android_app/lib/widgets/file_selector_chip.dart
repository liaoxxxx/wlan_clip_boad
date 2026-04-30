import 'dart:io';
import 'package:flutter/material.dart';
import '../features/file_manager/file_picker_service.dart';

/// 文件选择状态展示组件（单文件）
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

/// 已选图片横向预览列表
class SelectedImagePreview extends StatelessWidget {
  final List<FileMessageModel> files;
  final Function(FileMessageModel) onRemove;

  const SelectedImagePreview({
    super.key,
    required this.files,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Stack(
              children: [
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => onRemove(file),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    ),
                    child: Text(
                      file.name,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
