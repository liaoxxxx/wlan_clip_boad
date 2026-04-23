// 键盘输入辅助 - Windows 平台实现
// 此文件被延迟加载，仅在 Windows 平台使用

import 'dart:ffi';
import 'package:win32/win32.dart' as win32;
import 'clipboard_helper.dart';

/// 模拟键盘输入
Future<void> sendKeys(String text) async {
  try {
    for (int i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      
      if (charCode == 13) {
        _simulateKeyPress(win32.VK_RETURN);
      } else if (charCode == 9) {
        _simulateKeyPress(win32.VK_TAB);
      } else if (charCode == 8) {
        _simulateKeyPress(win32.VK_BACK);
      } else {
        final scanResult = win32.VkKeyScan(charCode);
        if (scanResult != -1) {
          final virtualKey = scanResult & 0xFF;
          final shiftState = (scanResult >> 8) & 0xFF;
          
          if (shiftState & 0x01 != 0) {
            _simulateKeyPress(win32.VK_SHIFT, hold: true);
          }
          if (shiftState & 0x02 != 0) {
            _simulateKeyPress(win32.VK_CONTROL, hold: true);
          }
          if (shiftState & 0x04 != 0) {
            _simulateKeyPress(win32.VK_MENU, hold: true);
          }
          
          _simulateKeyPress(virtualKey);
          
          if (shiftState & 0x04 != 0) {
            _simulateKeyRelease(win32.VK_MENU);
          }
          if (shiftState & 0x02 != 0) {
            _simulateKeyRelease(win32.VK_CONTROL);
          }
          if (shiftState & 0x01 != 0) {
            _simulateKeyRelease(win32.VK_SHIFT);
          }
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 5));
    }
  } catch (e) {
    print('❌ 键盘输入失败: $e');
  }
}

/// 模拟按键
void _simulateKeyPress(int virtualKey, {bool hold = false}) {
  final input = win32.INPUT.allocate();
  input.ref.type = win32.INPUT_KEYBOARD;
  input.ref.ki.wVk = virtualKey;
  input.ref.ki.dwFlags = 0;
  
  try {
    win32.SendInput(1, input, win32.sizeOf<win32.INPUT>());
  } finally {
    input.free();
  }
  
  if (!hold) {
    _simulateKeyRelease(virtualKey);
  }
}

/// 模拟释放按键
void _simulateKeyRelease(int virtualKey) {
  final input = win32.INPUT.allocate();
  input.ref.type = win32.INPUT_KEYBOARD;
  input.ref.ki.wVk = virtualKey;
  input.ref.ki.dwFlags = win32.KEYEVENTF_KEYUP;
  
  try {
    win32.SendInput(1, input, win32.sizeOf<win32.INPUT>());
  } finally {
    input.free();
  }
}

/// 使用剪贴板粘贴文本
Future<void> pasteText(String text) async {
  try {
    await WindowsClipboardHelper.setClipboard(text);
    await Future.delayed(const Duration(milliseconds: 50));
    
    _simulateKeyPress(win32.VK_CONTROL, hold: true);
    _simulateKeyPress(win32.VK_V);
    _simulateKeyRelease(win32.VK_CONTROL);
    
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    print('❌ 粘贴操作失败: $e');
  }
}
