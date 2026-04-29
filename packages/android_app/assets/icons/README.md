# Android 应用图标说明

## 📱 图标设计要求

### 核心元素
- **WiFi 信号图标**：体现无线连接特性
- **背景色**：蓝色渐变 (#2196F3 → #64B5F6)
- **风格**：Material Design，简洁现代
- **尺寸**：1024x1024 PNG（透明背景）

### 设计建议
```
图标描述：
- 背景：渐变色（蓝色 #2196F3 → 浅蓝 #64B5F6），体现科技感
- 中心元素：WiFi 信号图标（白色），三条弧形信号波从中心向外扩散
- 辅助元素：在 WiFi 图标下方添加一个简洁的手机轮廓（白色线条）
- 整体风格：Material Design 扁平化设计，圆角矩形
```

## 📁 文件位置

```
packages/android_app/assets/icons/
├── app_icon.png              # 主图标（1024x1024）
└── app_icon_foreground.png   # 前景图标（可选，用于自适应图标）
```

## 🔧 生成图标

### 步骤 1: 准备基础图标
使用在线工具创建 `app_icon.png`（1024x1024 PNG）：

推荐工具：
- **[IconKitchen](https://icon.kitchen/)** ⭐ 推荐
- **[Canva](https://www.canva.com/)**
- **[Figma](https://www.figma.com/)**

### 步骤 2: 运行图标生成工具

```bash
cd packages/android_app
flutter pub get
flutter pub run flutter_launcher_icons
```

### 步骤 3: 验证结果

检查以下目录是否已生成图标：
```
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

## 🎨 AI 生成提示词

**完整提示词指南请参考：** [AI_ICON_PROMPTS.md](../../../../AI_ICON_PROMPTS.md)

该文档提供针对 Midjourney、DALL-E 3、Stable Diffusion 的高质量英文提示词，包括：
- 多个设计方案（经典 WiFi、WiFi+手机、抽象科技）
- 平台特定参数和设置
- 优化技巧和常见问题解决

### 快速示例（Midjourney）

```bash
/imagine prompt: minimalist mobile app icon, centered white wifi signal symbol with three curved waves radiating outward, vibrant blue gradient background from #2196F3 to #64B5F6, material design style, flat design, clean geometric shapes, professional app icon, high contrast, simple and modern, 1024x1024 pixels, square composition, no text, isolated on solid color background --v 6.0 --style raw --no text, letters, words, complex details, shadows, gradients in icon
```

## ✅ 验证清单

- [ ] `app_icon.png` 已放置在 `assets/icons/`
- [ ] 运行 `flutter pub get`
- [ ] 运行 `flutter pub run flutter_launcher_icons`
- [ ] 检查 `android/app/src/main/res/mipmap-*/ic_launcher.png` 已更新
- [ ] 构建测试：`flutter build apk --release`
- [ ] 安装到设备验证图标显示正常

## 📝 注意事项

1. **自适应图标**：Android 8.0+ 支持自适应图标，需要前景和背景分离
2. **圆角处理**：系统会自动添加圆角，设计时预留安全区域
3. **背景色**：已在 `pubspec.yaml` 中设置为 `#2196F3`
4. **最小尺寸**：确保图标在所有尺寸下都清晰可辨
