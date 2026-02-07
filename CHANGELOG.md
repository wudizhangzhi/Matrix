# Changelog

All notable changes to Matrix Terminal will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-07

### Added

#### Toolbar Presets & Customization
- **Configurable toolbar profiles** with preset support (General, tmux, vim)
- **Custom toolbar creation** - users can create their own toolbar configurations
- **Toolbar editor UI** with drag-to-reorder and visibility toggles
- **Per-host toolbar profiles** - assign different toolbar configurations to different hosts
- **Comprehensive key catalog** including:
  - Modifier keys (Ctrl-A through Ctrl-Z)
  - Navigation keys (arrows, Home, End, PgUp, PgDn)
  - Function keys (F1-F12)
  - Special keys (Enter, Esc, Tab, Space, Backspace)

#### Clipboard Image Paste
- **Android platform channel** for reading clipboard images
- **Base64 encoding support** - paste images from clipboard as base64-encoded text
- **Confirmation dialog** showing image size and dimensions before pasting
- **Size limits and warnings** (500KB warning, 2MB hard limit)
- **Image preview thumbnail** in paste confirmation dialog

#### Android Notifications
- **Connection state notifications** - alerts for connect/disconnect events
- **Command completion notifications** - detect when commands finish (configurable prompt patterns)
- **Custom pattern triggers** - user-defined regex patterns for custom alerts
- **Multiple notification channels** for different event types
- **Background-only notifications** - only trigger when app is in background
- **Settings UI** for configuring notification preferences and patterns

#### Database & Storage
- **Drift database migration** from version 1 to 2
- **ToolbarProfiles table** for storing custom toolbar configurations
- **NotificationPatterns table** for custom notification triggers
- **JSON-encoded button storage** for flexible toolbar data

### Fixed
- Fixed curly braces lint warnings in settings screen

### Technical
- Added `flutter_local_notifications` v18.0.1 for notification support
- Enhanced background service with notification channels
- Improved terminal output monitoring with pattern matching
- Added clipboard service for image handling

## [1.0.0] - Initial Release

### Added
- **SSH client functionality** using dartssh2
- **Terminal emulation** with xterm.dart
- **Host management** - add, edit, delete SSH hosts
- **Host grouping** - organize hosts into collapsible groups
- **Password authentication** for SSH connections
- **Multi-tab sessions** - manage multiple SSH connections simultaneously
- **Chinese input support** - dedicated input bar for IME composing
- **Background service** - keep SSH connections alive in background
- **Dark theme** - modern UI with deep blue-purple color scheme
- **Secure storage** - encrypted password storage using flutter_secure_storage
- **SQLite database** - local storage with Drift ORM
- **WakeLock support** - prevent CPU sleep during active sessions
- **Session state management** using Riverpod
- **Custom terminal font** - JetBrains Mono for better code readability

### Features
- Connection state management (connecting, connected, disconnected, error)
- SSH keepalive (15s heartbeat)
- Visual connection status indicators
- Search functionality for host list
- Long-press context menu for hosts
- Expandable/collapsible host groups
- Bottom navigation (Hosts, Keychain, Settings)

[1.1.0]: https://github.com/wudizhangzhi/Matrix/releases/tag/v1.1.0
[1.0.0]: https://github.com/wudizhangzhi/Matrix/releases/tag/v1.0.0
