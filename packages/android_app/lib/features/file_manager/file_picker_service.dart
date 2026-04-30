import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clip_sync_common/clip_sync_common.dart';

/// 文件信息模型
class FileMessageModel {
  final String name;
  final int size;
  final String path;
  final bool isImage;

  FileMessageModel({
    required this.name,
    required this.size,
    required this.path,
    this.isImage = false,
  });

  Map<String, dynamic> toJson() => {
        'type': isImage ? 'image' : 'file',
        'name': name,
        'size': size,
        'path': path,
        if (isImage) 'data': _readAsBase64(),
      };

  String? _readAsBase64() {
    try {
      final file = File(path);
      final bytes = file.readAsBytesSync();
      return base64Encode(bytes);
    } catch (e) {
      print('读取图片文件失败: $e');
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());

  static FileMessageModel fromPlatformFile(PlatformFile file) {
    // 简单判断是否为图片
    final ext = file.extension?.toLowerCase();
    final isImg = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
    
    return FileMessageModel(
      name: file.name,
      size: file.size,
      path: file.path ?? '',
      isImage: isImg,
    );
  }
}

/// 文件选择服务
class FilePickerService {
  /// 检查并请求存储权限
  Future<bool> _ensurePermissions() async {
    // Android 13+ (API 33+) 需要申请细分权限
    if (await Permission.photos.isGranted ||
        await Permission.storage.isGranted) {
      return true;
    }

    // 尝试申请权限
    final status = await Permission.photos.request();
    if (status.isGranted) return true;

    // 如果 photos 权限被拒绝，尝试 storage (针对旧版本)
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// 选择多个图片文件
  Future<List<FileMessageModel>> pickMultipleImages() async {
    final hasPermission = await _ensurePermissions();
    if (!hasPermission) {
      print('存储权限被拒绝');
      return [];
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // 仅允许选择图片
        allowMultiple: true,
      );

      if (result != null) {
        final models = result.files
            .where((file) => file.path != null)
            .map((file) => FileMessageModel.fromPlatformFile(file))
            .toList();
        
        // 如果超过限制，截取前 N 张
        if (models.length > AppConstants.maxImageSelection) {
          return models.sublist(0, AppConstants.maxImageSelection);
        }
        return models;
      }
    } catch (e) {
      print('图片选择失败: $e');
    }
    return [];
  }
}
