# Toolbar Presets, Clipboard Image Paste, Notifications - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add three features to Matrix Terminal: configurable toolbar profiles with presets, clipboard image paste as base64, and Android local notifications for terminal events.

**Architecture:** Toolbar profiles stored in Drift DB with JSON-encoded button lists. Clipboard uses Android platform channel to read image bytes. Notifications use existing flutter_local_notifications with terminal output monitoring. All state managed via Riverpod. Database schema version bumps from 1 to 2 with migration.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod, flutter_local_notifications, Kotlin (platform channel), shared_preferences

---

## Feature 1: Toolbar Presets & Customization

### Task 1: Add ToolbarButton model and preset definitions

**Files:**
- Create: `lib/features/terminal/models/toolbar_button.dart`

**Step 1: Create the ToolbarButton model with JSON serialization and preset definitions**

```dart
// lib/features/terminal/models/toolbar_button.dart
import 'dart:convert';

class ToolbarButton {
  final String label;
  final String sequence;
  final bool highlight;

  const ToolbarButton({
    required this.label,
    required this.sequence,
    this.highlight = false,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'sequence': sequence,
        'highlight': highlight,
      };

  factory ToolbarButton.fromJson(Map<String, dynamic> json) => ToolbarButton(
        label: json['label'] as String,
        sequence: json['sequence'] as String,
        highlight: json['highlight'] as bool? ?? false,
      );

  static String encodeList(List<ToolbarButton> buttons) =>
      jsonEncode(buttons.map((b) => b.toJson()).toList());

  static List<ToolbarButton> decodeList(String json) =>
      (jsonDecode(json) as List)
          .map((e) => ToolbarButton.fromJson(e as Map<String, dynamic>))
          .toList();
}

/// All available keys organized by category for the key catalog picker.
class KeyCatalog {
  static const modifiers = <ToolbarButton>[
    ToolbarButton(label: 'Ctrl-A', sequence: '\x01'),
    ToolbarButton(label: 'Ctrl-B', sequence: '\x02'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: 'Ctrl-D', sequence: '\x04'),
    ToolbarButton(label: 'Ctrl-E', sequence: '\x05'),
    ToolbarButton(label: 'Ctrl-F', sequence: '\x06'),
    ToolbarButton(label: 'Ctrl-G', sequence: '\x07'),
    ToolbarButton(label: 'Ctrl-H', sequence: '\x08'),
    ToolbarButton(label: 'Ctrl-K', sequence: '\x0b'),
    ToolbarButton(label: 'Ctrl-L', sequence: '\x0c'),
    ToolbarButton(label: 'Ctrl-N', sequence: '\x0e'),
    ToolbarButton(label: 'Ctrl-O', sequence: '\x0f'),
    ToolbarButton(label: 'Ctrl-P', sequence: '\x10'),
    ToolbarButton(label: 'Ctrl-Q', sequence: '\x11'),
    ToolbarButton(label: 'Ctrl-R', sequence: '\x12'),
    ToolbarButton(label: 'Ctrl-S', sequence: '\x13'),
    ToolbarButton(label: 'Ctrl-T', sequence: '\x14'),
    ToolbarButton(label: 'Ctrl-U', sequence: '\x15'),
    ToolbarButton(label: 'Ctrl-V', sequence: '\x16'),
    ToolbarButton(label: 'Ctrl-W', sequence: '\x17'),
    ToolbarButton(label: 'Ctrl-X', sequence: '\x18'),
    ToolbarButton(label: 'Ctrl-Y', sequence: '\x19'),
    ToolbarButton(label: 'Ctrl-Z', sequence: '\x1a'),
  ];

  static const navigation = <ToolbarButton>[
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
    ToolbarButton(label: 'Home', sequence: '\x1b[H'),
    ToolbarButton(label: 'End', sequence: '\x1b[F'),
    ToolbarButton(label: 'PgUp', sequence: '\x1b[5~'),
    ToolbarButton(label: 'PgDn', sequence: '\x1b[6~'),
    ToolbarButton(label: 'Ins', sequence: '\x1b[2~'),
    ToolbarButton(label: 'Del', sequence: '\x1b[3~'),
  ];

  static const function_ = <ToolbarButton>[
    ToolbarButton(label: 'F1', sequence: '\x1bOP'),
    ToolbarButton(label: 'F2', sequence: '\x1bOQ'),
    ToolbarButton(label: 'F3', sequence: '\x1bOR'),
    ToolbarButton(label: 'F4', sequence: '\x1bOS'),
    ToolbarButton(label: 'F5', sequence: '\x1b[15~'),
    ToolbarButton(label: 'F6', sequence: '\x1b[17~'),
    ToolbarButton(label: 'F7', sequence: '\x1b[18~'),
    ToolbarButton(label: 'F8', sequence: '\x1b[19~'),
    ToolbarButton(label: 'F9', sequence: '\x1b[20~'),
    ToolbarButton(label: 'F10', sequence: '\x1b[21~'),
    ToolbarButton(label: 'F11', sequence: '\x1b[23~'),
    ToolbarButton(label: 'F12', sequence: '\x1b[24~'),
  ];

  static const special = <ToolbarButton>[
    ToolbarButton(label: 'Enter', sequence: '\r', highlight: true),
    ToolbarButton(label: 'Esc', sequence: '\x1b'),
    ToolbarButton(label: 'Tab', sequence: '\t'),
    ToolbarButton(label: 'Space', sequence: ' '),
    ToolbarButton(label: 'Bksp', sequence: '\x7f'),
  ];

  static List<ToolbarButton> get all => [
        ...special,
        ...modifiers,
        ...navigation,
        ...function_,
      ];
}

/// Built-in preset toolbar profiles.
class ToolbarPresets {
  static const general = <ToolbarButton>[
    ToolbarButton(label: 'Enter', sequence: '\r', highlight: true),
    ToolbarButton(label: 'Esc', sequence: '\x1b'),
    ToolbarButton(label: 'Tab', sequence: '\t'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: 'Ctrl-D', sequence: '\x04'),
    ToolbarButton(label: 'Ctrl-Z', sequence: '\x1a'),
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
    ToolbarButton(label: 'Home', sequence: '\x1b[H'),
    ToolbarButton(label: 'End', sequence: '\x1b[F'),
    ToolbarButton(label: 'PgUp', sequence: '\x1b[5~'),
    ToolbarButton(label: 'PgDn', sequence: '\x1b[6~'),
  ];

  static const tmux = <ToolbarButton>[
    ToolbarButton(label: 'Enter', sequence: '\r', highlight: true),
    ToolbarButton(label: 'Ctrl-B', sequence: '\x02', highlight: true),
    ToolbarButton(label: '%', sequence: '%'),
    ToolbarButton(label: '"', sequence: '"'),
    ToolbarButton(label: 'c', sequence: 'c'),
    ToolbarButton(label: 'n', sequence: 'n'),
    ToolbarButton(label: 'p', sequence: 'p'),
    ToolbarButton(label: 'd', sequence: 'd'),
    ToolbarButton(label: '[', sequence: '['),
    ToolbarButton(label: 'Esc', sequence: '\x1b'),
    ToolbarButton(label: 'Tab', sequence: '\t'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
  ];

  static const vim = <ToolbarButton>[
    ToolbarButton(label: 'Esc', sequence: '\x1b', highlight: true),
    ToolbarButton(label: ':', sequence: ':'),
    ToolbarButton(label: 'w', sequence: 'w'),
    ToolbarButton(label: 'q', sequence: 'q'),
    ToolbarButton(label: '!', sequence: '!'),
    ToolbarButton(label: 'i', sequence: 'i'),
    ToolbarButton(label: 'v', sequence: 'v'),
    ToolbarButton(label: 'Enter', sequence: '\r'),
    ToolbarButton(label: 'Ctrl-C', sequence: '\x03'),
    ToolbarButton(label: '\u2190', sequence: '\x1b[D'),
    ToolbarButton(label: '\u2192', sequence: '\x1b[C'),
    ToolbarButton(label: '\u2191', sequence: '\x1b[A'),
    ToolbarButton(label: '\u2193', sequence: '\x1b[B'),
    ToolbarButton(label: 'dd', sequence: 'dd'),
    ToolbarButton(label: 'yy', sequence: 'yy'),
  ];
}
```

**Step 2: Verify the file has no syntax errors**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/features/terminal/models/toolbar_button.dart`
Expected: No errors

**Step 3: Commit**

```bash
git add lib/features/terminal/models/toolbar_button.dart
git commit -m "feat(toolbar): add ToolbarButton model with presets and key catalog"
```

---

### Task 2: Add ToolbarProfiles table to Drift database and bump schema

**Files:**
- Modify: `lib/core/storage/database.dart`

**Step 1: Add ToolbarProfiles table and update schema version**

Add the `ToolbarProfiles` table class before `@DriftDatabase`. Update the annotation to include it. Add schema version 2 with migration. Add CRUD methods for toolbar profiles.

```dart
// Add before @DriftDatabase annotation:
class ToolbarProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  TextColumn get buttons => text()(); // JSON-encoded List<ToolbarButton>
}

// Update annotation:
@DriftDatabase(tables: [Hosts, HostGroups, ToolbarProfiles])

// Update schemaVersion to 2

// Add migration:
@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(toolbarProfiles);
        }
      },
    );

// Add methods:
Future<List<ToolbarProfile>> getAllToolbarProfiles() =>
    select(toolbarProfiles).get();

Stream<List<ToolbarProfile>> watchAllToolbarProfiles() =>
    select(toolbarProfiles).watch();

Future<int> insertToolbarProfile(ToolbarProfilesCompanion profile) =>
    into(toolbarProfiles).insert(profile);

Future<void> updateToolbarProfile(ToolbarProfilesCompanion profile) =>
    (update(toolbarProfiles)..where((p) => p.id.equals(profile.id.value)))
        .write(profile);

Future<void> deleteToolbarProfile(int id) =>
    (delete(toolbarProfiles)..where((p) => p.id.equals(id))).go();
```

**Step 2: Run build_runner to regenerate database code**

Run: `cd /Volumes/mac-extra/github/matrix && dart run build_runner build --delete-conflicting-outputs`
Expected: Build successful, `database.g.dart` regenerated

**Step 3: Verify no analysis errors**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/core/storage/database.dart`
Expected: No errors

**Step 4: Commit**

```bash
git add lib/core/storage/database.dart lib/core/storage/database.g.dart
git commit -m "feat(toolbar): add ToolbarProfiles table with schema migration v2"
```

---

### Task 3: Add shared_preferences dependency and toolbar Riverpod provider

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/terminal/providers/toolbar_provider.dart`

**Step 1: Add shared_preferences to pubspec.yaml**

Add under dependencies:
```yaml
  shared_preferences: ^2.3.4
```

Run: `cd /Volumes/mac-extra/github/matrix && flutter pub get`

**Step 2: Create toolbar provider**

```dart
// lib/features/terminal/providers/toolbar_provider.dart
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';
import 'package:matrix_terminal/features/terminal/models/toolbar_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _activeProfileKey = 'active_toolbar_profile_id';

/// Provides the active toolbar profile ID. -1 = General, -2 = tmux, -3 = vim.
/// Positive IDs are custom profiles from DB.
final activeToolbarProfileIdProvider = StateProvider<int>((ref) => -1);

/// Provides all custom (user-created) toolbar profiles from DB.
final customToolbarProfilesProvider = StreamProvider<List<ToolbarProfile>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllToolbarProfiles();
});

/// Represents a resolved toolbar profile with its buttons.
class ResolvedToolbarProfile {
  final int id; // -1=General, -2=tmux, -3=vim, positive=custom
  final String name;
  final List<ToolbarButton> buttons;
  final bool isBuiltIn;

  const ResolvedToolbarProfile({
    required this.id,
    required this.name,
    required this.buttons,
    required this.isBuiltIn,
  });
}

/// Provides the list of all available profiles (built-in + custom).
final allToolbarProfilesProvider = Provider<AsyncValue<List<ResolvedToolbarProfile>>>((ref) {
  final customAsync = ref.watch(customToolbarProfilesProvider);
  return customAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (customProfiles) {
      final profiles = <ResolvedToolbarProfile>[
        const ResolvedToolbarProfile(
          id: -1,
          name: 'General',
          buttons: ToolbarPresets.general,
          isBuiltIn: true,
        ),
        const ResolvedToolbarProfile(
          id: -2,
          name: 'tmux',
          buttons: ToolbarPresets.tmux,
          isBuiltIn: true,
        ),
        const ResolvedToolbarProfile(
          id: -3,
          name: 'vim',
          buttons: ToolbarPresets.vim,
          isBuiltIn: true,
        ),
        ...customProfiles.map((p) => ResolvedToolbarProfile(
              id: p.id,
              name: p.name,
              buttons: ToolbarButton.decodeList(p.buttons),
              isBuiltIn: false,
            )),
      ];
      return AsyncValue.data(profiles);
    },
  );
});

/// Provides the currently active toolbar profile's buttons.
final activeToolbarButtonsProvider = Provider<List<ToolbarButton>>((ref) {
  final activeId = ref.watch(activeToolbarProfileIdProvider);
  final profilesAsync = ref.watch(allToolbarProfilesProvider);
  return profilesAsync.when(
    loading: () => ToolbarPresets.general,
    error: (_, __) => ToolbarPresets.general,
    data: (profiles) {
      final match = profiles.where((p) => p.id == activeId);
      if (match.isEmpty) return ToolbarPresets.general;
      return match.first.buttons;
    },
  );
});

/// Helper to persist active profile ID.
class ToolbarProfileService {
  static Future<void> saveActiveProfileId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeProfileKey, id);
  }

  static Future<int> loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeProfileKey) ?? -1;
  }
}
```

**Step 3: Verify**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/features/terminal/providers/toolbar_provider.dart`
Expected: No errors

**Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/terminal/providers/toolbar_provider.dart
git commit -m "feat(toolbar): add Riverpod provider for toolbar profiles with persistence"
```

---

### Task 4: Refactor TerminalToolbar to use profile-driven buttons

**Files:**
- Modify: `lib/features/terminal/widgets/terminal_toolbar.dart`
- Modify: `lib/features/terminal/screens/terminal_screen.dart`

**Step 1: Rewrite TerminalToolbar as a ConsumerWidget that reads active profile**

```dart
// lib/features/terminal/widgets/terminal_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/features/terminal/models/toolbar_button.dart';
import 'package:matrix_terminal/features/terminal/providers/toolbar_provider.dart';

class TerminalToolbar extends ConsumerWidget {
  final void Function(String) onKey;
  final VoidCallback? onOpenEditor;

  const TerminalToolbar({super.key, required this.onKey, this.onOpenEditor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttons = ref.watch(activeToolbarButtonsProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buttons.map((btn) => _buildBtn(btn)).toList(),
              ),
            ),
          ),
          _gearBtn(),
        ],
      ),
    );
  }

  Widget _buildBtn(ToolbarButton btn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onKey(btn.sequence),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              btn.label,
              style: TextStyle(
                color: btn.highlight ? AppColors.primary : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gearBtn() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onOpenEditor,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.settings, color: AppColors.textSecondary, size: 18),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Update terminal_screen.dart to pass onOpenEditor**

In `terminal_screen.dart`, update the `TerminalToolbar` usage to add `onOpenEditor`:

```dart
TerminalToolbar(
  onKey: (seq) => activeSession?.writeText(seq),
  onOpenEditor: () {
    // Will be implemented in Task 5
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => const _ToolbarProfilePicker(),
    );
  },
),
```

Add a placeholder `_ToolbarProfilePicker` widget at the bottom of terminal_screen.dart (will be replaced by the real editor in Task 5).

**Step 3: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`
Expected: No errors

**Step 4: Commit**

```bash
git add lib/features/terminal/widgets/terminal_toolbar.dart lib/features/terminal/screens/terminal_screen.dart
git commit -m "feat(toolbar): refactor toolbar to use profile-driven buttons with gear icon"
```

---

### Task 5: Create toolbar editor bottom sheet (profile picker + reorder)

**Files:**
- Create: `lib/features/terminal/widgets/toolbar_editor.dart`
- Modify: `lib/features/terminal/screens/terminal_screen.dart` (replace placeholder)

**Step 1: Create the toolbar editor widget**

This is a bottom sheet with:
- Profile selector (horizontal chips: General, tmux, vim, custom ones)
- ReorderableListView of buttons in the active profile (for custom profiles)
- "New Profile" button that opens a dialog to name + pick keys from catalog

```dart
// lib/features/terminal/widgets/toolbar_editor.dart
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';
import 'package:matrix_terminal/features/terminal/models/toolbar_button.dart';
import 'package:matrix_terminal/features/terminal/providers/toolbar_provider.dart';

class ToolbarEditor extends ConsumerStatefulWidget {
  const ToolbarEditor({super.key});

  @override
  ConsumerState<ToolbarEditor> createState() => _ToolbarEditorState();
}

class _ToolbarEditorState extends ConsumerState<ToolbarEditor> {
  @override
  Widget build(BuildContext context) {
    final activeId = ref.watch(activeToolbarProfileIdProvider);
    final profilesAsync = ref.watch(allToolbarProfilesProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toolbar Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () => _createNewProfile(context),
                tooltip: 'New Profile',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Profile chips
          profilesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: AppColors.error)),
            data: (profiles) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profiles.map((p) {
                final isActive = p.id == activeId;
                return GestureDetector(
                  onLongPress: p.isBuiltIn
                      ? null
                      : () => _deleteProfile(context, p.id, p.name),
                  child: ChoiceChip(
                    label: Text(p.name),
                    selected: isActive,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) {
                      ref.read(activeToolbarProfileIdProvider.notifier).state =
                          p.id;
                      ToolbarProfileService.saveActiveProfileId(p.id);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Button preview for active profile
          const Text(
            'Buttons',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: _buildButtonList(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonList() {
    final buttons = ref.watch(activeToolbarButtonsProvider);
    final activeId = ref.watch(activeToolbarProfileIdProvider);
    final isCustom = activeId > 0;

    if (!isCustom) {
      // Built-in profiles: show read-only list
      return ListView(
        shrinkWrap: true,
        children: buttons
            .map((b) => ListTile(
                  dense: true,
                  leading: Container(
                    width: 48,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.label,
                      style: TextStyle(
                        color: b.highlight
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  title: Text(
                    _describeSequence(b.sequence),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ))
            .toList(),
      );
    }

    // Custom profiles: reorderable
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: (oldIndex, newIndex) =>
          _reorderButtons(activeId, buttons, oldIndex, newIndex),
      children: [
        for (int i = 0; i < buttons.length; i++)
          ListTile(
            key: ValueKey('$i-${buttons[i].label}'),
            dense: true,
            leading: Container(
              width: 48,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                buttons[i].label,
                style: TextStyle(
                  color: buttons[i].highlight
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              _describeSequence(buttons[i].sequence),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.error, size: 18),
              onPressed: () => _removeButton(activeId, buttons, i),
            ),
          ),
      ],
    );
  }

  String _describeSequence(String seq) {
    if (seq == '\r') return 'Enter (\\r)';
    if (seq == '\x1b') return 'Escape (\\x1b)';
    if (seq == '\t') return 'Tab (\\t)';
    if (seq == ' ') return 'Space';
    if (seq == '\x7f') return 'Backspace';
    if (seq.startsWith('\x1b[')) return 'ANSI: ${seq.substring(2)}';
    if (seq.startsWith('\x1bO')) return 'SS3: ${seq.substring(2)}';
    if (seq.length == 1 && seq.codeUnitAt(0) < 0x20) {
      return 'Ctrl-${String.fromCharCode(seq.codeUnitAt(0) + 0x40)}';
    }
    return 'Literal: $seq';
  }

  Future<void> _createNewProfile(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New Profile',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Profile name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();

    if (name == null || name.isEmpty) return;

    // Start with General preset as base
    final db = ref.read(databaseProvider);
    final id = await db.insertToolbarProfile(ToolbarProfilesCompanion(
      name: Value(name),
      isBuiltIn: const Value(false),
      buttons: Value(ToolbarButton.encodeList(ToolbarPresets.general)),
    ));

    ref.read(activeToolbarProfileIdProvider.notifier).state = id;
    await ToolbarProfileService.saveActiveProfileId(id);
  }

  Future<void> _deleteProfile(
      BuildContext context, int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Profile',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "$name"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final db = ref.read(databaseProvider);
    await db.deleteToolbarProfile(id);

    // Switch back to General if the deleted profile was active
    final activeId = ref.read(activeToolbarProfileIdProvider);
    if (activeId == id) {
      ref.read(activeToolbarProfileIdProvider.notifier).state = -1;
      await ToolbarProfileService.saveActiveProfileId(-1);
    }
  }

  void _reorderButtons(
      int profileId, List<ToolbarButton> buttons, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final reordered = [...buttons];
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    _updateProfileButtons(profileId, reordered);
  }

  void _removeButton(int profileId, List<ToolbarButton> buttons, int index) {
    final updated = [...buttons]..removeAt(index);
    _updateProfileButtons(profileId, updated);
  }

  void _updateProfileButtons(int profileId, List<ToolbarButton> buttons) {
    final db = ref.read(databaseProvider);
    db.updateToolbarProfile(ToolbarProfilesCompanion(
      id: Value(profileId),
      buttons: Value(ToolbarButton.encodeList(buttons)),
    ));
  }
}

/// Bottom sheet to pick keys from catalog and add to a custom profile.
class KeyCatalogPicker extends ConsumerWidget {
  final int profileId;
  final List<ToolbarButton> currentButtons;

  const KeyCatalogPicker({
    super.key,
    required this.profileId,
    required this.currentButtons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = {
      'Special': KeyCatalog.special,
      'Modifiers': KeyCatalog.modifiers,
      'Navigation': KeyCatalog.navigation,
      'Function': KeyCatalog.function_,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Keys',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((btn) {
                        final alreadyAdded = currentButtons
                            .any((b) => b.sequence == btn.sequence);
                        return ActionChip(
                          label: Text(btn.label),
                          backgroundColor: alreadyAdded
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.background,
                          labelStyle: TextStyle(
                            color: alreadyAdded
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          onPressed: alreadyAdded
                              ? null
                              : () => _addButton(context, ref, btn),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _addButton(BuildContext context, WidgetRef ref, ToolbarButton btn) {
    final updated = [...currentButtons, btn];
    final db = ref.read(databaseProvider);
    db.updateToolbarProfile(ToolbarProfilesCompanion(
      id: Value(profileId),
      buttons: Value(ToolbarButton.encodeList(updated)),
    ));
    Navigator.pop(context);
  }
}
```

**Step 2: Update terminal_screen.dart to use ToolbarEditor**

Replace the placeholder `_ToolbarProfilePicker` with the import and usage of `ToolbarEditor`:

```dart
// In terminal_screen.dart imports:
import 'package:matrix_terminal/features/terminal/widgets/toolbar_editor.dart';

// In the onOpenEditor callback:
onOpenEditor: () {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    builder: (_) => const ToolbarEditor(),
  );
},
```

**Step 3: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`
Expected: No errors

**Step 4: Commit**

```bash
git add lib/features/terminal/widgets/toolbar_editor.dart lib/features/terminal/screens/terminal_screen.dart
git commit -m "feat(toolbar): add toolbar editor with profile picker, reorder, key catalog"
```

---

### Task 6: Load saved profile on app startup

**Files:**
- Modify: `lib/app/app.dart` (or main.dart, wherever the app initializes)

**Step 1: Find the app entry point and load the saved profile ID on startup**

Look for `main.dart` or `app.dart`. In the `main()` function or ProviderScope overrides, load the saved profile ID and set it on `activeToolbarProfileIdProvider`.

The simplest approach: in `terminal_screen.dart`, load the saved ID in an `initState` or `ref.listen` on first build. Or add a provider override.

Actually, the cleanest approach is to change `activeToolbarProfileIdProvider` to an `AsyncNotifier` that auto-loads on init. But to keep things simple, just add a load call in the terminal screen's build:

```dart
// In terminal_screen.dart, at top of build():
// Use a FutureProvider that loads once
final savedProfileIdProvider = FutureProvider<int>((ref) async {
  return ToolbarProfileService.loadActiveProfileId();
});
```

Then in `TerminalScreen.build()`:
```dart
ref.listen(savedProfileIdProvider, (_, next) {
  next.whenData((id) {
    if (ref.read(activeToolbarProfileIdProvider) != id) {
      ref.read(activeToolbarProfileIdProvider.notifier).state = id;
    }
  });
});
```

**Step 2: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`

**Step 3: Commit**

```bash
git add lib/features/terminal/screens/terminal_screen.dart lib/features/terminal/providers/toolbar_provider.dart
git commit -m "feat(toolbar): load saved toolbar profile on app startup"
```

---

## Feature 2: Clipboard Image Paste as Base64

### Task 7: Create Android platform channel for clipboard image reading

**Files:**
- Modify: `android/app/src/main/kotlin/com/matrix/terminal/matrix_terminal/MainActivity.kt`

**Step 1: Implement the platform channel in Kotlin**

```kotlin
package com.matrix.terminal.matrix_terminal

import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.matrix.terminal/clipboard"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getClipboardImage" -> {
                        val imageBytes = getClipboardImageBytes()
                        if (imageBytes != null) {
                            result.success(imageBytes)
                        } else {
                            result.success(null)
                        }
                    }
                    "hasClipboardImage" -> {
                        result.success(hasClipboardImage())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasClipboardImage(): Boolean {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = clipboard.primaryClip ?: return false
        if (clip.itemCount == 0) return false
        val item = clip.getItemAt(0)
        val uri = item.uri ?: return false
        val mimeType = contentResolver.getType(uri) ?: return false
        return mimeType.startsWith("image/")
    }

    private fun getClipboardImageBytes(): ByteArray? {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = clipboard.primaryClip ?: return null
        if (clip.itemCount == 0) return null

        val item = clip.getItemAt(0)
        val uri = item.uri ?: return null

        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream.close()

            if (bitmap == null) return null

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            bitmap.recycle()
            outputStream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
}
```

**Step 2: Commit**

```bash
git add android/app/src/main/kotlin/com/matrix/terminal/matrix_terminal/MainActivity.kt
git commit -m "feat(clipboard): add Android platform channel for clipboard image reading"
```

---

### Task 8: Create Flutter clipboard service

**Files:**
- Create: `lib/core/clipboard/clipboard_service.dart`

**Step 1: Create the Dart-side clipboard service**

```dart
// lib/core/clipboard/clipboard_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ClipboardImageService {
  static const _channel = MethodChannel('com.matrix.terminal/clipboard');

  /// Returns image bytes from clipboard, or null if no image.
  static Future<Uint8List?> getClipboardImage() async {
    try {
      final result = await _channel.invokeMethod<Uint8List>('getClipboardImage');
      return result;
    } on PlatformException {
      return null;
    }
  }

  /// Returns true if clipboard contains an image.
  static Future<bool> hasClipboardImage() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasClipboardImage');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Convert image bytes to base64 string.
  static String toBase64(Uint8List bytes) => base64Encode(bytes);

  /// Format as a shell command that decodes base64 to a file.
  static String toShellCommand(Uint8List bytes, {String path = '/tmp/clipboard.png'}) {
    final b64 = base64Encode(bytes);
    return "echo '$b64' | base64 -d > $path";
  }
}
```

**Step 2: Verify**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/core/clipboard/clipboard_service.dart`

**Step 3: Commit**

```bash
git add lib/core/clipboard/clipboard_service.dart
git commit -m "feat(clipboard): add Flutter clipboard image service with base64 conversion"
```

---

### Task 9: Add paste button to toolbar and confirmation dialog

**Files:**
- Modify: `lib/features/terminal/widgets/terminal_toolbar.dart`
- Create: `lib/features/terminal/widgets/paste_image_dialog.dart`

**Step 1: Create the paste image confirmation dialog**

```dart
// lib/features/terminal/widgets/paste_image_dialog.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/clipboard/clipboard_service.dart';

/// Shows a confirmation dialog for pasting clipboard image as base64.
/// Returns the text to paste, or null if cancelled.
Future<String?> showPasteImageDialog(BuildContext context, Uint8List imageBytes) {
  final sizeKb = (imageBytes.length / 1024).toStringAsFixed(1);
  final base64Size = ((imageBytes.length * 4 / 3) / 1024).toStringAsFixed(1);

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Paste Image',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thumbnail preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              imageBytes,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Image: $sizeKb KB\nBase64 output: ~$base64Size KB',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if (imageBytes.length > 512 * 1024)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '⚠ Large image - may be slow to paste',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final cmd = ClipboardImageService.toShellCommand(imageBytes);
            Navigator.pop(ctx, cmd);
          },
          child: const Text('As Command'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx, ClipboardImageService.toBase64(imageBytes));
          },
          child: const Text('Raw Base64'),
        ),
      ],
    ),
  );
}
```

**Step 2: Add a paste button in terminal_toolbar.dart**

In the `TerminalToolbar.build()`, add a paste icon button next to the gear button:

```dart
// In the Row children, between Expanded and _gearBtn():
_pasteBtn(context),
```

Add a new method:
```dart
Widget _pasteBtn(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _handlePaste(context),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.content_paste, color: AppColors.textSecondary, size: 18),
        ),
      ),
    ),
  );
}

Future<void> _handlePaste(BuildContext context) async {
  final imageBytes = await ClipboardImageService.getClipboardImage();
  if (imageBytes == null) {
    // No image - fall back to text paste
    final textData = await Clipboard.getData(Clipboard.kTextPlain);
    if (textData?.text != null) {
      onKey(textData!.text!);
    }
    return;
  }

  if (imageBytes.length > 2 * 1024 * 1024) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image too large (max 2MB)')),
      );
    }
    return;
  }

  if (!context.mounted) return;
  final result = await showPasteImageDialog(context, imageBytes);
  if (result != null) {
    onKey(result);
  }
}
```

Add imports:
```dart
import 'package:flutter/services.dart';
import 'package:matrix_terminal/core/clipboard/clipboard_service.dart';
import 'package:matrix_terminal/features/terminal/widgets/paste_image_dialog.dart';
```

Note: Since `_handlePaste` is async and uses context, `TerminalToolbar` needs to become `StatelessWidget` with a `Builder` or pass context. The simplest approach: pass `BuildContext` from the build method into the button callback.

**Step 3: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`

**Step 4: Commit**

```bash
git add lib/features/terminal/widgets/paste_image_dialog.dart lib/features/terminal/widgets/terminal_toolbar.dart
git commit -m "feat(clipboard): add paste button with image base64 confirmation dialog"
```

---

## Feature 3: Android Notifications for Terminal Events

### Task 10: Add NotificationPatterns table to database

**Files:**
- Modify: `lib/core/storage/database.dart`

**Step 1: Add NotificationPatterns table, bump schema to 3**

```dart
// Add table class:
class NotificationPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pattern => text()();
  TextColumn get title => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

// Update annotation:
@DriftDatabase(tables: [Hosts, HostGroups, ToolbarProfiles, NotificationPatterns])

// Update schemaVersion to 3

// Update migration:
@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(toolbarProfiles);
        }
        if (from < 3) {
          await m.createTable(notificationPatterns);
        }
      },
    );

// Add CRUD methods:
Future<List<NotificationPattern>> getAllNotificationPatterns() =>
    select(notificationPatterns).get();

Stream<List<NotificationPattern>> watchNotificationPatterns() =>
    select(notificationPatterns).watch();

Future<void> insertNotificationPattern(NotificationPatternsCompanion p) =>
    into(notificationPatterns).insert(p);

Future<void> updateNotificationPattern(NotificationPatternsCompanion p) =>
    (update(notificationPatterns)..where((t) => t.id.equals(p.id.value)))
        .write(p);

Future<void> deleteNotificationPattern(int id) =>
    (delete(notificationPatterns)..where((t) => t.id.equals(id))).go();
```

**Step 2: Regenerate**

Run: `cd /Volumes/mac-extra/github/matrix && dart run build_runner build --delete-conflicting-outputs`

**Step 3: Verify**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/core/storage/database.dart`

**Step 4: Commit**

```bash
git add lib/core/storage/database.dart lib/core/storage/database.g.dart
git commit -m "feat(notifications): add NotificationPatterns table with schema migration v3"
```

---

### Task 11: Create notification service

**Files:**
- Create: `lib/core/notifications/notification_service.dart`

**Step 1: Create notification service with channels and send methods**

```dart
// lib/core/notifications/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _notificationId = 100; // Start above foreground service ID (888)

  static const _connectionChannel = AndroidNotificationChannel(
    'connection_status',
    'Connection Status',
    description: 'SSH connection state changes',
    importance: Importance.high,
  );

  static const _commandChannel = AndroidNotificationChannel(
    'command_alerts',
    'Command Alerts',
    description: 'Command completion notifications',
    importance: Importance.defaultImportance,
  );

  static const _customChannel = AndroidNotificationChannel(
    'custom_triggers',
    'Custom Triggers',
    description: 'Custom pattern match notifications',
    importance: Importance.defaultImportance,
  );

  static Future<void> init() async {
    if (_initialized) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(initSettings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_connectionChannel);
    await androidPlugin?.createNotificationChannel(_commandChannel);
    await androidPlugin?.createNotificationChannel(_customChannel);

    _initialized = true;
  }

  static Future<void> showConnectionNotification({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'connection_status',
          'Connection Status',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showCommandNotification({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'command_alerts',
          'Command Alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  static Future<void> showCustomTriggerNotification({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_triggers',
          'Custom Triggers',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }
}
```

**Step 2: Verify**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/core/notifications/notification_service.dart`

**Step 3: Commit**

```bash
git add lib/core/notifications/notification_service.dart
git commit -m "feat(notifications): add notification service with connection, command, and custom channels"
```

---

### Task 12: Create terminal output monitor

**Files:**
- Create: `lib/core/notifications/terminal_monitor.dart`

**Step 1: Create the terminal output monitor that watches SSH output for patterns**

```dart
// lib/core/notifications/terminal_monitor.dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:matrix_terminal/core/notifications/notification_service.dart';
import 'package:matrix_terminal/core/ssh/ssh_service.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TerminalMonitor with WidgetsBindingObserver {
  static TerminalMonitor? _instance;
  static TerminalMonitor get instance => _instance ??= TerminalMonitor._();

  TerminalMonitor._();

  bool _isBackground = false;
  final _sessionSubscriptions = <String, StreamSubscription<SessionState>>{};

  // Settings keys
  static const keyConnectionNotif = 'notif_connection';
  static const keyCommandNotif = 'notif_command';
  static const keyPromptPattern = 'notif_prompt_pattern';

  // Defaults
  static const defaultPromptPattern = r'[\$#>]\s*$';

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final sub in _sessionSubscriptions.values) {
      sub.cancel();
    }
    _sessionSubscriptions.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isBackground = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden;
  }

  bool get isBackground => _isBackground;

  /// Start monitoring a session for connection state changes.
  void watchSession(SshSession session) {
    // Cancel existing subscription if any
    _sessionSubscriptions[session.id]?.cancel();

    SessionState? previousState;
    _sessionSubscriptions[session.id] =
        session.stateStream.listen((state) async {
      if (!_isBackground) {
        previousState = state;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final connectionEnabled = prefs.getBool(keyConnectionNotif) ?? true;

      if (connectionEnabled && previousState != null) {
        final hostLabel = session.host.label;
        if (state == SessionState.disconnected &&
            previousState == SessionState.connected) {
          await NotificationService.showConnectionNotification(
            title: 'Disconnected',
            body: '$hostLabel has disconnected',
          );
        } else if (state == SessionState.connected &&
            previousState != SessionState.connected) {
          await NotificationService.showConnectionNotification(
            title: 'Connected',
            body: '$hostLabel is now connected',
          );
        } else if (state == SessionState.error) {
          await NotificationService.showConnectionNotification(
            title: 'Connection Error',
            body: '$hostLabel: ${session.errorMessage ?? "Unknown error"}',
          );
        }
      }

      previousState = state;
    });
  }

  /// Stop monitoring a session.
  void unwatchSession(String sessionId) {
    _sessionSubscriptions[sessionId]?.cancel();
    _sessionSubscriptions.remove(sessionId);
  }

  /// Check terminal output text against patterns.
  /// Call this from the SSH stdout listener.
  Future<void> checkOutput({
    required String text,
    required String hostLabel,
    required List<NotificationPattern> patterns,
  }) async {
    if (!_isBackground) return;

    final prefs = await SharedPreferences.getInstance();

    // Check command completion (prompt detection)
    final commandEnabled = prefs.getBool(keyCommandNotif) ?? true;
    if (commandEnabled) {
      final promptPattern =
          prefs.getString(keyPromptPattern) ?? defaultPromptPattern;
      try {
        final regex = RegExp(promptPattern);
        if (regex.hasMatch(text)) {
          await NotificationService.showCommandNotification(
            title: 'Command Completed',
            body: '$hostLabel: command finished',
          );
        }
      } catch (_) {
        // Invalid regex, skip
      }
    }

    // Check custom patterns
    for (final p in patterns) {
      if (!p.enabled) continue;
      try {
        final regex = RegExp(p.pattern);
        if (regex.hasMatch(text)) {
          await NotificationService.showCustomTriggerNotification(
            title: p.title,
            body: '$hostLabel matched: ${p.pattern}',
          );
        }
      } catch (_) {
        // Invalid regex, skip
      }
    }
  }
}
```

**Step 2: Verify**

Run: `cd /Volumes/mac-extra/github/matrix && dart analyze lib/core/notifications/terminal_monitor.dart`

**Step 3: Commit**

```bash
git add lib/core/notifications/terminal_monitor.dart
git commit -m "feat(notifications): add terminal output monitor with background detection"
```

---

### Task 13: Integrate terminal monitor with SSH sessions

**Files:**
- Modify: `lib/core/ssh/ssh_service.dart`
- Modify: `lib/features/terminal/providers/session_provider.dart`

**Step 1: Add output monitoring hook in SshSession**

In `ssh_service.dart`, add a callback for output monitoring. In the `connect()` method's stdout listener, call the monitor:

```dart
// Add to SshSession class:
void Function(String text)? onOutputForMonitor;

// In connect(), update the stdout listener:
_shell!.stdout.listen(
  (data) {
    final text = utf8.decode(data, allowMalformed: true);
    terminal.write(text);
    onOutputForMonitor?.call(text);
  },
  onDone: () {
    state = SessionState.disconnected;
    _stateController.add(state);
  },
);
```

**Step 2: In session_provider.dart, wire up the monitor**

```dart
// Add import:
import 'package:matrix_terminal/core/notifications/terminal_monitor.dart';
import 'package:matrix_terminal/core/storage/database.dart';

// In SessionManagerNotifier.connect(), after creating the session:
final monitor = TerminalMonitor.instance;
monitor.watchSession(session);

// Add output monitoring with custom patterns
final db = ref.read(databaseProvider);
session.onOutputForMonitor = (text) async {
  final patterns = await db.getAllNotificationPatterns();
  await monitor.checkOutput(
    text: text,
    hostLabel: host.label,
    patterns: patterns,
  );
};

// In closeSession():
TerminalMonitor.instance.unwatchSession(state.sessions[index].id);
```

**Step 3: Initialize the monitor in main.dart**

In `main()`:
```dart
TerminalMonitor.instance.init();
```

**Step 4: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`

**Step 5: Commit**

```bash
git add lib/core/ssh/ssh_service.dart lib/features/terminal/providers/session_provider.dart lib/main.dart
git commit -m "feat(notifications): integrate terminal monitor with SSH sessions"
```

---

### Task 14: Add notification settings UI

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart`

**Step 1: Add notification settings section**

Add a "NOTIFICATIONS" section between the "TERMINAL" and "ABOUT" sections in settings_screen.dart. This section contains:

- Toggle for connection state notifications
- Toggle for command completion notifications
- Text field for prompt pattern regex
- List of custom patterns with add/delete
- "Test Notification" button

This requires converting `SettingsScreen` from `ConsumerWidget` to `ConsumerStatefulWidget` to manage the custom patterns state, OR use a provider. Simplest: use providers.

```dart
// Add these providers at the top of settings_screen.dart:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_terminal/core/notifications/terminal_monitor.dart';
import 'package:matrix_terminal/core/notifications/notification_service.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';

final connectionNotifProvider = StateProvider<bool>((ref) => true);
final commandNotifProvider = StateProvider<bool>((ref) => true);
final promptPatternProvider = StateProvider<String>(
    (ref) => TerminalMonitor.defaultPromptPattern);

final notificationPatternsProvider =
    StreamProvider<List<NotificationPattern>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchNotificationPatterns();
});
```

Add the NOTIFICATIONS section in the ListView children:

```dart
const SizedBox(height: 24),

// Notifications section
const Text(
  'NOTIFICATIONS',
  style: TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  ),
),
const SizedBox(height: 12),
Card(
  child: Column(
    children: [
      SwitchListTile(
        title: const Text('Connection Status',
            style: TextStyle(color: AppColors.textPrimary)),
        subtitle: const Text('Notify on disconnect/reconnect',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        value: ref.watch(connectionNotifProvider),
        activeColor: AppColors.primary,
        onChanged: (v) async {
          ref.read(connectionNotifProvider.notifier).state = v;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(TerminalMonitor.keyConnectionNotif, v);
        },
      ),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('Command Completion',
            style: TextStyle(color: AppColors.textPrimary)),
        subtitle: const Text('Notify when commands finish',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        value: ref.watch(commandNotifProvider),
        activeColor: AppColors.primary,
        onChanged: (v) async {
          ref.read(commandNotifProvider.notifier).state = v;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(TerminalMonitor.keyCommandNotif, v);
        },
      ),
      const Divider(height: 1),
      ListTile(
        title: const Text('Test Notification',
            style: TextStyle(color: AppColors.primary)),
        leading: const Icon(Icons.notifications_active, color: AppColors.primary),
        onTap: () {
          NotificationService.showConnectionNotification(
            title: 'Test',
            body: 'Notifications are working!',
          );
        },
      ),
    ],
  ),
),

// Custom patterns
const SizedBox(height: 16),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'CUSTOM TRIGGERS',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    ),
    IconButton(
      icon: const Icon(Icons.add, color: AppColors.primary, size: 20),
      onPressed: () => _addPattern(context, ref),
    ),
  ],
),
const SizedBox(height: 8),
ref.watch(notificationPatternsProvider).when(
  loading: () => const SizedBox(),
  error: (_, __) => const SizedBox(),
  data: (patterns) => Card(
    child: Column(
      children: patterns.isEmpty
          ? [
              const ListTile(
                title: Text('No custom triggers',
                    style: TextStyle(color: AppColors.textSecondary)),
                subtitle: Text('Tap + to add a regex pattern trigger',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            ]
          : patterns.map((p) => ListTile(
                title: Text(p.title,
                    style: const TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(p.pattern,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: () {
                    ref.read(databaseProvider).deleteNotificationPattern(p.id);
                  },
                ),
              )).toList(),
    ),
  ),
),
```

Add `_addPattern` method:

```dart
void _addPattern(BuildContext context, WidgetRef ref) {
  final titleCtrl = TextEditingController();
  final patternCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Add Custom Trigger',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Notification Title',
              hintText: 'Build Complete',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: patternCtrl,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              labelText: 'Regex Pattern',
              hintText: 'BUILD SUCCESSFUL',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (titleCtrl.text.trim().isEmpty ||
                patternCtrl.text.trim().isEmpty) return;
            ref.read(databaseProvider).insertNotificationPattern(
                  NotificationPatternsCompanion(
                    title: Value(titleCtrl.text.trim()),
                    pattern: Value(patternCtrl.text.trim()),
                  ),
                );
            Navigator.pop(ctx);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
```

**Step 2: Load saved notification preferences on build**

Add a load step that reads SharedPreferences and sets the providers. Use `ref.listen` or load in `initState` if converting to StatefulWidget.

**Step 3: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`

**Step 4: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "feat(notifications): add notification settings UI with custom pattern triggers"
```

---

### Task 15: Initialize notification service in app startup

**Files:**
- Modify: `lib/main.dart`

**Step 1: Add notification service init in main()**

```dart
import 'package:matrix_terminal/core/notifications/notification_service.dart';
import 'package:matrix_terminal/core/notifications/terminal_monitor.dart';

// In main():
await NotificationService.init();
TerminalMonitor.instance.init();
```

**Step 2: Verify build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`

**Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(notifications): initialize notification service and terminal monitor on startup"
```

---

### Task 16: Final build verification

**Step 1: Run full analyze**

Run: `cd /Volumes/mac-extra/github/matrix && flutter analyze`
Expected: No errors

**Step 2: Run build**

Run: `cd /Volumes/mac-extra/github/matrix && flutter build apk --debug`
Expected: Build successful

**Step 3: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix: address build issues from feature implementation"
```
