// 键盘输入辅助 - Windows 平台实现
// 此文件被延迟加载，仅在 Windows 平台使用

import 'clipboard_helper.dart';

/// 模拟键盘输入（暂时禁用）
Future<void> sendKeys(String text) async {
  print('⚠️ 逐字符输入功能暂时禁用');
  print('💡 建议使用粘贴方式（Ctrl+V）');
}

/// 使用剪贴板粘贴文本
Future<void> pasteText(String text) async {
  try {
    // 写入剪贴板
    await WindowsClipboardHelper.setClipboard(text);
    print('✅ 文本已写入剪贴板，请手动按 Ctrl+V 粘贴');
  } catch (e) {
    print('❌ 操作失败: $e');
  }
}
