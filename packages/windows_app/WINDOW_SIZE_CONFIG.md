# 📐 Windows 应用窗口大小设置

## ✅ 修改完成

### 窗口尺寸
- **宽度**: 380 像素
- **高度**: 700 像素
- **位置**: (10, 10) - 距离屏幕左上角

---

## 🔧 修改内容

### 文件: `windows/runner/main.cpp`

```cpp
// 修改前
Win32Window::Size size(1280, 720);

// 修改后
Win32Window::Size size(380, 700);  // Width: 380px, Height: 700px
```

**位置**: 第 29 行

---

## 📊 效果对比

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 宽度 | 1280 px | **380 px** ✅ |
| 高度 | 720 px | **700 px** ✅ |
| 宽高比 | 16:9 | ~1:1.84 |
| 适用场景 | 桌面全屏 | 侧边栏/窄屏 |

---

## 💡 设计考虑

### 为什么选择 380px 宽度？

1. **紧凑布局** - 适合放在屏幕一侧
2. **信息完整** - 足够显示所有功能
3. **不遮挡** - 不会占用太多屏幕空间
4. **移动友好** - 类似手机屏幕比例

### 高度 700px 的原因

1. **内容完整** - 可以显示所有 UI 元素
2. **滚动需求** - 如果内容更多可以滚动
3. **屏幕适配** - 适合大多数显示器

---

## 🎨 UI 适配建议

### 当前布局
```
┌──────────────────────┐  ← 380px
│  💻 Windows 剪贴板    │  ← AppBar
├──────────────────────┤
│  🖥️ 服务器状态        │
│  ✅ 服务运行中         │
│  端口: 8889           │
├──────────────────────┤
│  📝 接收的文本 [复制] │
│  ┌──────────────────┐│
│  │ 等待接收文本...   ││
│  └──────────────────┘│
├──────────────────────┤
│  ⌨️ 输入模式          │
│  ☑ 自动输入模式       │
├──────────────────────┤
│  💡 提示:             │
│  • 自动输入已开启     │
├──────────────────────┤
│  📜 连接日志:         │
│  ┌──────────────────┐│
│  │ 15:30:25 ✅ ...  ││
│  │ 15:30:30 📱 ...  ││
│  └──────────────────┘│
└──────────────────────┘
```

### 优化建议

如果 380px 宽度导致某些内容显示不全，可以考虑：

1. **缩小字体** - 减小文字大小
2. **简化布局** - 减少 padding/margin
3. **隐藏次要信息** - 折叠不常用的区域
4. **使用图标** - 用图标代替文字标签

---

## 🔍 如何调整窗口大小

### 方法 1: 修改 C++ 代码（推荐）

编辑 `windows/runner/main.cpp` 第 29 行：

```cpp
Win32Window::Size size(宽度, 高度);
```

例如：
```cpp
// 更窄的窗口
Win32Window::Size size(320, 700);

// 更宽的窗口
Win32Window::Size size(450, 700);

// 正方形窗口
Win32Window::Size size(400, 400);
```

### 方法 2: 运行时调整

用户可以在运行时手动拖动窗口边缘调整大小。

---

## ⚠️ 注意事项

### 1. 最小宽度限制
Flutter 和 Windows 可能有最小窗口宽度限制，如果设置太小可能无法生效。

**建议最小值**: 320px

### 2. 内容溢出
如果窗口太窄，可能导致内容溢出或显示不全。

**解决方案**:
- 使用 `SingleChildScrollView` 包裹内容
- 使用 `Flexible` 和 `Expanded` 自适应布局
- 测试不同宽度下的显示效果

### 3. 高分辨率屏幕
在高分辨率屏幕上，380px 可能看起来很小。

**解决方案**:
- 考虑 DPI 缩放
- 使用逻辑像素而非物理像素

---

## 🧪 测试建议

### 测试场景

1. **不同分辨率**
   - 1920x1080 (Full HD)
   - 2560x1440 (2K)
   - 3840x2160 (4K)

2. **不同 DPI 缩放**
   - 100% (无缩放)
   - 125%
   - 150%
   - 200%

3. **内容长度**
   - 短文本 (< 50 字符)
   - 中等文本 (50-200 字符)
   - 长文本 (> 200 字符)

4. **UI 元素**
   - 按钮是否可点击
   - 文字是否可读
   - 滚动是否流畅

---

## 📝 相关代码

### main.cpp (完整上下文)

```cpp
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(380, 700);  // Width: 380px, Height: 700px
  if (!window.Create(L"clip_sync_wifi", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
```

---

## 🎯 下一步优化

如果需要进一步优化窗口大小和布局：

1. **收集用户反馈** - 了解实际使用体验
2. **A/B 测试** - 测试不同的窗口尺寸
3. **响应式设计** - 根据窗口大小自动调整布局
4. **保存用户偏好** - 记住用户调整的窗口大小

---

**修改时间**: 2026-04-24  
**修改文件**: `packages/windows_app/windows/runner/main.cpp`  
**窗口尺寸**: 380 x 700 像素  
