# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Clip Sync WiFi is a Flutter-based cross-platform clipboard synchronization system using WebSocket over WiFi. The Windows app acts as a WebSocket server that receives text from the Android client and can either auto-type it into the focused window or copy it to the clipboard.

## Monorepo Structure

This is a monorepo with three independent packages:

- **`packages/common/`** - Shared code (constants, utilities, WebSocket types)
- **`packages/windows_app/`** - Windows WebSocket server with clipboard/keyboard automation
- **`packages/android_app/`** - Android WebSocket client with voice recognition

Each app references the common package via path dependency:
```yaml
dependencies:
  clip_sync_common:
    path: ../common
```

**Important**: After modifying `packages/common/`, run `flutter pub get` in both app directories to update dependencies.

## Build Commands

### Development Mode

Windows:
```bash
cd packages/windows_app
flutter pub get
flutter run -d windows
```

Android:
```bash
cd packages/android_app
flutter pub get
flutter run -d <device-id>  # Use `flutter devices` to list devices
```

### Release Builds

Windows:
```bash
cd packages/windows_app
.\build_release.bat
# Output: release/windows/clip_sync_wifi.exe
```

Android:
```bash
cd packages/android_app
.\build_release.bat
# Output: release/android/clip_sync_android.apk
```

Manual build commands:
- Windows: `flutter build windows --release`
- Android: `flutter build apk --release`

### Testing

Run tests from each package directory:
```bash
cd packages/<package_name>
flutter test
```

## Architecture

### Communication Flow

```
[Android Client] ---(WiFi: WebSocket)---> [Windows Server:8889]
                                          |
                                          +--> Auto-type (Ctrl+V or char-by-char)
                                          +--> Clipboard only
```

### Key Components

**Windows App** (`packages/windows_app/lib/windows/`):
- `windows_server.dart` - WebSocket server (HttpServer + WebSocket upgrade)
- `clipboard_helper.dart` - Win32 API clipboard operations
- `keyboard_input_helper.dart` - Keyboard simulation (deferred loading)
- `tray_manager.dart` - System tray integration

**Android App** (`packages/android_app/lib/`):
- `android_client.dart` - WebSocket client with auto-reconnect

**Common Package** (`packages/common/lib/`):
- `constants.dart` - Port (8889), debounce delay (500ms), reconnect interval
- `utils.dart` - DebounceHelper, AppLogger

### Platform Isolation

- Windows app uses `win32` and `ffi` packages - these are NOT in the Android app's dependencies
- Android app has no Windows-specific code
- Shared logic lives in `packages/common/`

### Important Patterns

1. **Deferred Loading**: `keyboard_input_helper.dart` uses deferred loading to avoid loading Win32 code until needed
2. **Debouncing**: Text input is debounced by 500ms before sending over WebSocket
3. **Auto-reconnect**: Android client automatically reconnects every 3 seconds on disconnect
4. **Collapsible UI**: Windows app has collapsible modules (server status, input mode, logs, etc.)
5. **Always-on-top**: Windows app supports floating window mode via `bitsdojo_window`

## Network Configuration

- **Port**: 8889 (defined in `AppConstants.defaultWebsocketPort`)
- **Protocol**: WebSocket over HTTP (ws://)
- **Firewall**: Windows firewall must allow inbound TCP on port 8889
- **Network**: Both devices must be on the same WiFi network

To add firewall rule:
```powershell
New-NetFirewallRule -DisplayName "ClipSync WiFi" -Direction Inbound -LocalPort 8889 -Protocol TCP -Action Allow
```

## Windows-Specific Details

### Window Configuration

Window size is set in `packages/windows_app/windows/runner/main.cpp`:
```cpp
Win32Window::Size size(380, 700);  // Width: 380px, Height: 700px
```

### Auto-Type Modes

The Windows app supports two auto-type methods:
1. **Paste method (Ctrl+V)** - Fast and accurate, recommended for long text
2. **Character-by-character** - Better compatibility but slower

Both use Win32 API (`SendInput`) for keyboard simulation.

### System Tray

The app minimizes to system tray instead of closing. The tray icon provides quick access to show/hide the window.

## Common Development Tasks

### Adding Shared Constants

1. Add to `packages/common/lib/constants.dart`
2. Export in `packages/common/lib/clip_sync_common.dart` if needed
3. Run `flutter pub get` in both app directories

### Modifying WebSocket Protocol

1. Update message handling in `windows_server.dart` (server side)
2. Update message sending in `android_client.dart` (client side)
3. Update shared types/constants in `packages/common/` if needed

### Debugging Connection Issues

1. Check Windows app logs (connection log module)
2. Verify IP address shown in Windows app matches Android client config
3. Test network connectivity: `ping <windows-ip>` from Android device
4. Check firewall rules: `netstat -ano | findstr :8889`

## Dependencies

Key dependencies:
- `web_socket_channel: ^2.4.0` - WebSocket communication (both platforms)
- `win32: ^5.2.0` - Windows API access (Windows only)
- `ffi: ^2.1.0` - Foreign function interface (Windows only)
- `bitsdojo_window: ^0.1.6` - Window management (Windows only)
- `system_tray: ^2.0.3` - System tray (Windows only)
- `shared_preferences: ^2.2.2` - Settings persistence (both platforms)

## Release Directory Structure

Each platform's `release/` directory contains only that platform's build output:
- `packages/android_app/release/android/` - APK only
- `packages/windows_app/release/windows/` - EXE and dependencies only

This is enforced by platform-specific `.gitignore` rules.
