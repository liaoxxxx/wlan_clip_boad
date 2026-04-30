import 'dart:convert';

/// 图片消息模型
class ImageMessageModel {
  final String name;
  final int size;
  final String base64Data; // 使用 Base64 传输图片内容

  ImageMessageModel({
    required this.name,
    required this.size,
    required this.base64Data,
  });

  Map<String, dynamic> toJson() => {
        'type': 'image',
        'name': name,
        'size': size,
        'data': base64Data,
      };

  static ImageMessageModel? fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'image' || json['data'] == null) return null;
    return ImageMessageModel(
      name: json['name'] ?? 'unknown.jpg',
      size: json['size'] ?? 0,
      base64Data: json['data'],
    );
  }
}
