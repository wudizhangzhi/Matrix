# Matrix Terminal

[![Release APK](https://github.com/wudizhangzhi/Matrix/actions/workflows/build-apk.yml/badge.svg)](https://github.com/wudizhangzhi/Matrix/actions/workflows/build-apk.yml)
[![Latest Release](https://img.shields.io/github/v/release/wudizhangzhi/Matrix)](https://github.com/wudizhangzhi/Matrix/releases/latest)
[![License](https://img.shields.io/github/license/wudizhangzhi/Matrix)](LICENSE)

A modern SSH client built with Flutter, designed for Android with comprehensive Chinese input support.

## ✨ Features

### Core Functionality
- 🔐 **SSH Client** - Full-featured SSH connection support
- 🖥️ **Terminal Emulation** - Powered by xterm.dart
- 📱 **Multi-Session Management** - Handle multiple SSH connections with tabs
- 🌐 **Chinese Input Support** - Dedicated input bar for seamless IME composing
- 🔒 **Secure Storage** - Encrypted password storage
- 🌙 **Dark Theme** - Modern deep blue-purple UI

### Advanced Features (v1.1.0+)
- ⌨️ **Configurable Toolbar Presets** - General, tmux, vim profiles
- 🎨 **Custom Toolbar Editor** - Create and customize your own key layouts
- 📋 **Clipboard Image Paste** - Paste images as base64-encoded text
- 🔔 **Smart Notifications** - Connection alerts, command completion, custom patterns
- 🎯 **Per-Host Profiles** - Different toolbar configurations for different hosts

### Host Management
- 📁 **Group Organization** - Organize hosts into collapsible groups
- 🔍 **Search & Filter** - Quick host discovery
- 💾 **SQLite Database** - Reliable local storage with Drift ORM
- 🔄 **Background Service** - Keep connections alive in background

## 📥 Download

Download the latest APK from [Releases](https://github.com/wudizhangzhi/Matrix/releases/latest).

## 🚀 Quick Start

### Prerequisites
- Android 5.0+ (API 21)
- SSH server access

### Installation
1. Download the APK from releases
2. Install on your Android device
3. Grant necessary permissions
4. Add your first SSH host
5. Connect and enjoy!

## 🛠️ Development

### Requirements
- Flutter SDK 3.10.0 or higher
- Dart SDK
- Android SDK with API 21+
- Java 17

### Setup

```bash
# Clone the repository
git clone https://github.com/wudizhangzhi/Matrix.git
cd Matrix

# Install dependencies
flutter pub get

# Generate code (for Drift database)
flutter pub run build_runner build

# Run the app
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 📖 Documentation

- [CHANGELOG.md](CHANGELOG.md) - Version history and changes
- [docs/RELEASE.md](docs/RELEASE.md) - Release process guide
- [docs/plans/](docs/plans/) - Design and implementation documents

## 🏗️ Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter |
| SSH Protocol | dartssh2 |
| Terminal | xterm |
| State Management | Riverpod |
| Local Database | Drift (SQLite) |
| Secure Storage | flutter_secure_storage |
| Background Service | flutter_background_service |
| Notifications | flutter_local_notifications |

## 🎯 Roadmap

### Current (v1.1.0)
- ✅ Toolbar presets and customization
- ✅ Clipboard image paste
- ✅ Android notifications

### Next Release
- ⏳ SSH key authentication (generate/import)
- ⏳ TOTP multi-factor authentication
- ⏳ Custom terminal color schemes
- ⏳ Font size adjustment
- ⏳ Auto-reconnect

### Future
- 📱 iOS support
- 📁 SFTP file management
- 🔀 Port forwarding
- 📝 Snippets management

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

## 🙏 Acknowledgments

- [dartssh2](https://pub.dev/packages/dartssh2) - Pure Dart SSH implementation
- [xterm](https://pub.dev/packages/xterm) - Flutter terminal emulator
- [Riverpod](https://riverpod.dev/) - State management
- [Drift](https://drift.simonbinder.eu/) - Type-safe SQLite for Flutter

## 📞 Support

If you encounter any issues or have questions, please [open an issue](https://github.com/wudizhangzhi/Matrix/issues) on GitHub.
