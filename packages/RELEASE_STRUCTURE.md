# Release 目录结构说明

## 📁 目录组织原则

每个平台的 `release/` 目录**只包含该平台**的构建产物，不包含其他平台的文件。

### Android 应用
```
packages/android_app/release/
└── android/
    └── clip_sync_android.apk    # Android APK 文件
```

### Windows 应用
```
packages/windows_app/release/
└── windows/
    ├── clip_sync_usb.exe        # Windows 可执行文件
    ├── flutter_windows.dll      # Flutter 运行时
    └── data/                    # 资源文件
        └── flutter_assets/
```

## 🔨 构建方法

### 构建 Android APK
```bash
cd packages/android_app
.\build_release.bat
```

构建完成后，APK 将位于：`release/android/clip_sync_android.apk`

### 构建 Windows EXE
```bash
cd packages/windows_app
.\build_release.bat
```

构建完成后，EXE 将位于：`release/windows/clip_sync_usb.exe`

## ⚠️ 注意事项

1. **不要交叉放置文件**
   - ❌ 不要在 `android_app/release/` 中放置 Windows 文件
   - ❌ 不要在 `windows_app/release/` 中放置 Android 文件
   - ✅ 每个平台只管理自己的构建产物

2. **Git 忽略规则**
   - `.gitignore` 已配置为只跟踪对应平台的子目录
   - Android: 只跟踪 `release/android/`
   - Windows: 只跟踪 `release/windows/`

3. **清理旧文件**
   - 如果 release 目录中有其他平台的文件，请手动删除
   - 运行构建脚本会自动清理并重新生成

## 📦 发布流程

1. 分别构建两个平台的应用
2. 从各自的 `release/{platform}/` 目录获取构建产物
3. 如需打包分发，可以创建统一的发布包：
   ```
   release_package/
   ├── android/
   │   └── clip_sync_android.apk
   ├── windows/
   │   └── clip_sync_usb.exe (及相关文件)
   └── README.md
   ```
