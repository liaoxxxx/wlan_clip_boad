# 应用图标说明

## 📱 Android 端图标

### 设计要求
- **核心元素**：WiFi 信号图标，体现无线连接特性
- **背景色**：蓝色渐变 (#2196F3)
- **风格**：Material Design，简洁现代
- **尺寸**：1024x1024 PNG（透明背景）

### 文件位置
```
packages/android_app/assets/icons/
├── app_icon.png              # 主图标（1024x1024）
└── app_icon_foreground.png   # 前景图标（可选，用于自适应图标）
```

### 生成图标
```bash
cd packages/android_app
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## 💻 Windows 端图标

### 设计要求
- **核心元素**：剪贴板 + 同步箭头，体现桌面管理
- **背景色**：深蓝色 (#1976D2)
- **风格**：Windows Fluent Design，专业稳重
- **尺寸**：1024x1024 PNG（透明背景）

### 文件位置
```
packages/windows_app/assets/icons/
├── app_icon.png              # 主图标（1024x1024）
└── tray_icon.ico             # 托盘图标（多尺寸 ICO）
```

### 生成图标
```bash
cd packages/windows_app
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## 🎨 快速生成工具推荐

### 在线工具
1. **[IconKitchen](https://icon.kitchen/)** ⭐ 推荐
   - 免费、在线
   - Material Design 风格
   - 直接下载适配图标

2. **[Canva](https://www.canva.com/)**
   - 搜索 "app icon" 模板
   - 拖拽式设计

3. **[Figma Community](https://www.figma.com/community)**
   - 免费模板
   - 专业级设计

### AI 生成提示词

**完整提示词指南请参考：** [AI_ICON_PROMPTS.md](../../../../AI_ICON_PROMPTS.md)

该文档提供针对 Midjourney、DALL-E 3、Stable Diffusion 的高质量英文提示词，包括：
- 多个设计方案（经典剪贴板、剪贴板+WiFi、抽象同步）
- 平台特定参数和设置
- 优化技巧和常见问题解决

### 快速示例（Midjourney）

**Android 图标：**
```bash
/imagine prompt: minimalist mobile app icon, centered white wifi signal symbol with three curved waves radiating outward, vibrant blue gradient background from #2196F3 to #64B5F6, material design style, flat design, clean geometric shapes, professional app icon, high contrast, simple and modern, 1024x1024 pixels, square composition, no text, isolated on solid color background --v 6.0 --style raw --no text, letters, words, complex details, shadows, gradients in icon
```

**Windows 图标：**
```bash
/imagine prompt: professional desktop application icon, white clipboard icon with two bidirectional sync arrows (circular arrows), centered composition, deep blue background (#1976D2), windows fluent design style, modern and clean, flat vector art, subtle depth, productivity software icon, clipboard management concept, 1024x1024 pixels, square format, no text, corporate professional aesthetic --v 6.0 --style raw --no text, letters, words, realistic clipboard, paper sheets, shadows, complex details
```

---

## 🔧 托盘图标生成

### 方法 1：在线转换
1. 准备 PNG 图标（256x256）
2. 访问 https://convertio.co/png-ico/
3. 上传 PNG，转换为 ICO
4. 下载并命名为 `tray_icon.ico`

### 方法 2：使用 ImageMagick
```bash
magick convert app_icon.png -define icon:auto-resize=16,32,48 tray_icon.ico
```

### 方法 3：使用 GIMP
1. 打开 PNG 文件
2. 文件 → 导出为
3. 选择 .ico 格式
4. 选择多个尺寸（16, 32, 48）

---

## ✅ 验证清单

### Android
- [ ] `app_icon.png` 已放置在 `assets/icons/`
- [ ] 运行 `flutter pub run flutter_launcher_icons`
- [ ] 检查 `android/app/src/main/res/mipmap-*/ic_launcher.png`
- [ ] 构建测试：`flutter build apk --release`

### Windows
- [ ] `app_icon.png` 已放置在 `assets/icons/`
- [ ] `tray_icon.ico` 已放置在 `assets/icons/`（可选）
- [ ] 运行 `flutter pub run flutter_launcher_icons`
- [ ] 检查 `windows/runner/resources/app_icon.ico`
- [ ] 构建测试：`flutter build windows --release`
