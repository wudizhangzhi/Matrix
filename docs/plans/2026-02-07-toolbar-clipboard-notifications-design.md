# Feature Design: Toolbar Presets, Clipboard Image Paste, Notifications

Date: 2026-02-07

## 1. Toolbar Presets & Customization

### Goal

Replace the hardcoded toolbar with a configurable system supporting preset profiles, user reordering, and modifier combo buttons.

### Preset Profiles

- **General** (default): Enter, Esc, Tab, Ctrl-C, Ctrl-D, Ctrl-Z, arrow keys, Home, End, PgUp, PgDn
- **tmux** (Ctrl+B prefix): Ctrl-B, %, ", c, n, p, d, [, plus General keys
- **vim**: Esc, :, w, q, !, i, v, dd, yy, plus Ctrl-C
- **Custom**: User creates from a catalog of available keys

### Data Model

```dart
// Drift table
class ToolbarProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  TextColumn get buttons => text()(); // JSON-encoded list of ToolbarButton
}

class ToolbarButton {
  final String label;    // Display text, e.g. "Ctrl-A"
  final String sequence; // Escape sequence, e.g. "\x01"
  final bool highlight;  // Primary color highlight
}
```

- Stored in Drift database for persistence
- Each host can optionally reference a profile ID (nullable FK on hosts table)
- Default profile ID stored in SharedPreferences

### UI

- Gear icon on the toolbar opens edit mode
- Edit mode: drag to reorder, toggle visibility per button, switch profile via dropdown
- "New Profile" screen: pick buttons from a categorized catalog (Modifiers, Navigation, Function keys, Custom)
- Profile selector accessible from terminal screen (swipe or dropdown)

### Key Catalog

| Category    | Keys                                                    |
|-------------|---------------------------------------------------------|
| Modifiers   | Ctrl-A through Ctrl-Z (maps to \x01-\x1a)              |
| Navigation  | Arrow keys, Home, End, PgUp, PgDn, Insert, Delete      |
| Function    | F1-F12 (ANSI escape sequences)                          |
| Special     | Enter, Esc, Tab, Space, Backspace                       |

---

## 2. Clipboard Image Paste as Base64

### Goal

Allow users to paste screenshots/images from the Android clipboard into the terminal as base64-encoded text.

### Implementation

1. **Platform channel** to read clipboard image bytes (Flutter's default Clipboard API only handles text)
2. On paste action, check clipboard for image content type
3. If image found, show confirmation dialog: "Paste image as base64? (size: X KB)"
4. On confirm, convert to base64 and send to terminal stdin
5. Optionally wrap as command: `echo '<base64>' | base64 -d > /tmp/clipboard.png`

### Platform Channel (Android)

```kotlin
// MethodChannel: "com.matrix.terminal/clipboard"
// Method: "getClipboardImage"
// Returns: Uint8List of PNG bytes, or null if no image
```

### Size Limits

- Warn if image > 500KB (base64 output ~670KB of text)
- Hard limit at 2MB to prevent terminal flooding
- Show image dimensions and size in confirmation dialog

### UI

- New "Paste" button on toolbar (or integrate with system paste)
- Confirmation dialog with image preview thumbnail, dimensions, and base64 size estimate
- Option to paste raw base64 or wrapped command

---

## 3. Android Notifications for Terminal Events

### Goal

Local notifications for command completion, connection state changes, and custom text pattern matches when the app is in background.

### Notification Categories

#### 3a. Connection State

- Trigger on state transitions: connected -> disconnected, disconnected -> connected, any -> error
- Notification content: "[hostname] disconnected", "[hostname] reconnected"
- Uses existing `SessionState` enum - add a listener on state changes

#### 3b. Command Completion

- Detect shell prompt reappearing after command output
- Default prompt patterns: `$ `, `# `, `> ` at start of line
- User-configurable prompt regex in Settings
- Only notify when app is in background (check `WidgetsBindingObserver.didChangeAppLifecycleState`)

#### 3c. Custom Pattern Triggers

- User-defined regex patterns with custom notification titles
- Example: pattern `BUILD SUCCESSFUL` -> notification "Build Completed"
- Example: pattern `error:` -> notification "Error Detected"
- Patterns stored in Drift database

### Data Model

```dart
class NotificationPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pattern => text()();       // Regex pattern
  TextColumn get title => text()();         // Notification title
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}
```

### Implementation

- Use existing `flutter_local_notifications` package
- Android notification channels:
  - `connection_status`: Connection state changes (high importance)
  - `command_alerts`: Command completion (default importance)
  - `custom_triggers`: Pattern matches (default importance)
- Terminal output monitoring: add a listener on the xterm terminal output stream that checks patterns
- Background detection via `WidgetsBindingObserver`

### Settings UI

New "Notifications" section in Settings screen:
- Toggle: Connection state notifications (on/off)
- Toggle: Command completion notifications (on/off)
- Text field: Prompt pattern regex (with default)
- List: Custom patterns (add/edit/delete with regex test button)
- "Test Notification" button to verify setup

---

## Implementation Priority

1. **Toolbar presets** - Core UX improvement, most user-visible impact
2. **Notifications** - High utility for background SSH sessions
3. **Clipboard image paste** - Nice-to-have, lower priority

## Files to Create/Modify

### Toolbar
- `lib/core/storage/database.dart` - Add ToolbarProfiles table
- `lib/features/terminal/widgets/terminal_toolbar.dart` - Refactor to use profiles
- `lib/features/terminal/widgets/toolbar_editor.dart` - New: edit mode UI
- `lib/features/terminal/providers/toolbar_provider.dart` - New: Riverpod provider for profiles
- `lib/features/host/screens/host_edit_screen.dart` - Add profile selector

### Clipboard
- `android/app/src/main/kotlin/.../ClipboardPlugin.kt` - New: platform channel
- `lib/core/clipboard/clipboard_service.dart` - New: clipboard image reading
- `lib/features/terminal/widgets/terminal_toolbar.dart` - Add paste button

### Notifications
- `lib/core/storage/database.dart` - Add NotificationPatterns table
- `lib/core/notifications/notification_service.dart` - New: notification logic
- `lib/core/notifications/terminal_monitor.dart` - New: output pattern monitoring
- `lib/features/settings/screens/settings_screen.dart` - Add notification settings
