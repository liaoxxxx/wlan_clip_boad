# 托盘图标说明

## 如何添加自定义托盘图标

1. 准备一个 `.ico` 格式的图标文件（建议尺寸：16x16, 32x32, 48x48）
2. 将图标文件命名为 `tray_icon.ico`
3. 将此文件放在当前目录下

## 如果没有自定义图标

系统会使用默认的 Windows 应用图标作为托盘图标。

## 图标制作工具推荐

- [ICO Convert](https://www.icoconvert.com/) - 在线 PNG/JPG 转 ICO
- [GIMP](https://www.gimp.org/) - 免费图像编辑器，可导出 ICO
- [ImageMagick](https://imagemagick.org/) - 命令行工具

示例命令（使用 ImageMagick）：
```bash
convert icon.png -define icon:auto-resize=16,32,48 tray_icon.ico
```
