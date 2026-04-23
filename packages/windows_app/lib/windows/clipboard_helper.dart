import 'dart:ffi';
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
}
