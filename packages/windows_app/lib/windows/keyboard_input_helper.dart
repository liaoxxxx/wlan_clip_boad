// 键盘输入辅助 - Windows 平台实现
// 此文件被延迟加载，仅在 Windows 平台使用

import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win32;
import 'clipboard_helper.dart';

/// 模拟键盘输入（暂时禁用）
Future<void> sendKeys(String text) async {
  print('⚠️ 逐字符输入功能暂时禁用');
  print('💡 建议使用粘贴方式（Ctrl+V）');
}

/// 使用剪贴板粘贴文本（真正自动执行 Ctrl+V）
/// 优化版本：在粘贴前先清除目标输入框的旧内容，避免文本拼接
Future<void> pasteText(String text) async {
  try {
    print('📋 [粘贴] 开始执行自动粘贴流程...');
    
    // 1. 清除目标输入框的旧内容
    print('🧹 [粘贴] 步骤 1/4: 清除旧内容 (Ctrl+A + Delete)...');
    await _clearCurrentInput();
    print('✅ [粘贴] 旧内容已清除');
    
    // 2. 写入新文本到剪贴板
    print('📋 [粘贴] 步骤 2/4: 写入新文本到剪贴板...');
    await WindowsClipboardHelper.setClipboard(text);
    print('✅ [粘贴] 剪贴板写入成功 (${text.length} 字符)');
    
    // 3. 等待一小段时间确保剪贴板更新完成
    await Future.delayed(const Duration(milliseconds: 50));
    
    // 4. 模拟按下 Ctrl+V 粘贴
    print('📋 [粘贴] 步骤 3/4: 模拟 Ctrl+V 按键...');
    await _simulateKeyPress(win32.VK_CONTROL, win32.VK_V);
    print('✅ [粘贴] Ctrl+V 已发送');
    
    // 5. 等待粘贴操作完成
    await Future.delayed(const Duration(milliseconds: 100));
    print('📋 [粘贴] 步骤 4/4: 等待粘贴完成...');
    
    print('🎉 [粘贴] 自动粘贴流程全部完成！');
  } catch (e, stackTrace) {
    print('❌ [粘贴] 操作失败: $e');
    print('📍 [粘贴] 堆栈跟踪:\n$stackTrace');
    rethrow;
  }
}

/// 模拟组合键按下（如 Ctrl+V）
Future<void> _simulateKeyPress(int key1, int key2) async {
  try {
    // 分配 INPUT 结构数组
    final inputSize = ffi.sizeOf<win32.INPUT>();
    final inputs = calloc<win32.INPUT>(4);
    
    try {
      // 按下 Ctrl
      inputs[0]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = key1
        ..ki.dwFlags = 0;
      
      // 按下第二个键
      inputs[1]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = key2
        ..ki.dwFlags = 0;
      
      // 释放第二个键
      inputs[2]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = key2
        ..ki.dwFlags = win32.KEYEVENTF_KEYUP;
      
      // 释放 Ctrl
      inputs[3]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = key1
        ..ki.dwFlags = win32.KEYEVENTF_KEYUP;
      
      // 发送输入事件
      final result = win32.SendInput(4, inputs, inputSize);
      
      if (result == 4) {
        print('✅ [按键] 组合键 ($key1 + $key2) 模拟成功');
      } else {
        print('⚠️ [按键] 部分按键可能未成功发送 (result=$result)');
      }
    } finally {
      calloc.free(inputs);
    }
  } catch (e) {
    print('❌ [按键] 组合键模拟失败: $e');
    rethrow;
  }
}

/// 清除当前输入框的内容（使用 Ctrl+A + Delete）
Future<void> _clearCurrentInput() async {
  try {
    // 分配 INPUT 结构数组 - 需要 6 个按键事件
    final inputSize = ffi.sizeOf<win32.INPUT>();
    final inputs = calloc<win32.INPUT>(6);
    
    try {
      // 第1步：Ctrl+A (全选)
      // 按下 Ctrl
      inputs[0]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = win32.VK_CONTROL
        ..ki.dwFlags = 0;
      
      // 按下 A
      inputs[1]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = win32.VK_A
        ..ki.dwFlags = 0;
      
      // 释放 A
      inputs[2]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = win32.VK_A
        ..ki.dwFlags = win32.KEYEVENTF_KEYUP;
      
      // 释放 Ctrl
      inputs[3]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = win32.VK_CONTROL
        ..ki.dwFlags = win32.KEYEVENTF_KEYUP;
      
      // 短暂延迟，让全选操作生效
      await Future.delayed(const Duration(milliseconds: 30));
      
      // 第2步：Delete (删除选中内容)
      // 按下 Delete
      inputs[4]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = win32.VK_DELETE
        ..ki.dwFlags = 0;
      
      // 释放 Delete
      inputs[5]
        ..type = win32.INPUT_KEYBOARD
        ..ki.wVk = win32.VK_DELETE
        ..ki.dwFlags = win32.KEYEVENTF_KEYUP;
      
      // 发送所有输入事件
      final result = win32.SendInput(6, inputs, inputSize);
      
      if (result == 6) {
        print('✅ [清除] Ctrl+A + Delete 执行成功');
      } else {
        print('⚠️ [清除] 部分按键可能未成功发送 (result=$result)');
      }
      
      // 等待删除操作完成
      await Future.delayed(const Duration(milliseconds: 50));
    } finally {
      calloc.free(inputs);
    }
  } catch (e) {
    print('❌ [清除] 清除输入框失败: $e');
    rethrow;
  }
}
