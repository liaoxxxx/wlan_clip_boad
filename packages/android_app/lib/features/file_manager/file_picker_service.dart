import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// 文件信息模型
class FileMessageModel {
  final String name;
  final int size;
  final String path;

  FileMessageModel({
    required this.name,
    required this.size,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
        'type': 'file',
        'name': name,
        'size': size,
        'path': path,
      };

  String toJsonString() => jsonEncode(toJson());

  static FileMessageModel fromPlatformFile(PlatformFile file) {
    return FileMessageModel(
      name: file.name,
      size: file.size,
      path: file.path ?? '',
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

  /// 选择单个文件（支持图片和通用文件）
  Future<FileMessageModel?> pickFile() async {
    final hasPermission = await _ensurePermissions();
    if (!hasPermission) {
      print('存储权限被拒绝');
      return null;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // 允许选择任何类型的文件
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return FileMessageModel.fromPlatformFile(result.files.single);
      }
    } catch (e) {
      print('文件选择失败: $e');
    }
    return null;
  }
}
