import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart' as win32;
import 'package:clip_sync_common/clip_sync_common.dart';

/// Windows 平台剪贴板操作实现
class WindowsClipboardHelper {
  /// 使用 Win32 API 写入剪贴板
  static Future<void> setClipboard(String text) async {
    try {
      final hMem = win32.GlobalAlloc(win32.GMEM_MOVEABLE, text.length * 2 + 2);
      if (hMem.address == 0) return;

      final ptr = win32.GlobalLock(hMem);
      if (ptr.address == 0) {
        win32.GlobalFree(hMem);
        return;
      }

      final buffer = text.codeUnits;
      final typedPtr = ptr.cast<Uint16>();
      for (int i = 0; i < buffer.length; i++) {
        typedPtr.elementAt(i).value = buffer[i];
      }
      typedPtr.elementAt(buffer.length).value = 0; // 结尾空字符
      win32.GlobalUnlock(hMem);

      if (win32.OpenClipboard(0) != 0) {
        win32.EmptyClipboard();
        win32.SetClipboardData(win32.CF_UNICODETEXT, hMem.address);
        win32.CloseClipboard();
      }
      
      win32.GlobalFree(hMem);
    } catch (e) {
      print('❌ 剪贴板写入失败: $e');
    }
  }

  /// 使用 Win32 API 将图片数据写入剪贴板
  /// 注意：Windows 剪贴板需要 DIB (Device Independent Bitmap) 格式
  /// 当前实现：将图片保存为临时文件并使用 Shell API 复制到剪贴板
  static Future<bool> setImageToClipboard(Uint8List imageData) async {
    try {
      // 由于直接将 PNG/JPG 转换为 DIB 格式非常复杂，
      // 我们采用一个实用方案：使用 Flutter 的 Clipboard 类（仅支持文本）
      // 或者提示用户手动操作
      
      // 方案：暂时不支持直接复制图片到剪贴板
      // Windows 原生剪贴板图片需要复杂的 GDI+ 或 WIC 接口调用
      // 建议使用第三方库如 'clipboard_manager' 或 'screenshot'
      
      print('⚠️ 图片复制到剪贴板功能需要使用系统 API');
      print('   建议：先保存图片，然后在文件管理器中手动复制');
      
      return false;
    } catch (e) {
      print('❌ 图片剪贴板写入失败: $e');
      return false;
    }
  }
}
