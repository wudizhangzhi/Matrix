# Matrix Terminal Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Flutter SSH client app (Android-first) with Termius-style UI and proper Chinese input support.

**Architecture:** Clean Architecture with feature-based modules. dartssh2 for SSH, xterm for terminal rendering, Riverpod for state management. Drift for local DB (SQLite-based, actively maintained), flutter_secure_storage for secrets.

**Tech Stack:** Flutter 3.38+, Dart 3.10+, dartssh2, xterm, flutter_riverpod, drift, flutter_secure_storage, flutter_background_service, wakelock_plus

**Note on DB change:** Using Drift instead of Isar. Isar is abandoned by its author. Drift is SQLite-based, actively maintained, with compile-time safety and better long-term support.

---

### Task 1: Flutter Project Scaffold

**Files:**
- Create: `pubspec.yaml` (via flutter create)
- Create: `lib/main.dart`
- Create: `lib/app/app.dart`
- Create: `lib/app/theme.dart`

**Step 1: Create Flutter project**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
# Remove existing files that conflict (keep docs/ and .git/)
flutter create --org com.matrix.terminal --project-name matrix_terminal --platforms=android,ios .
```

Expected: Flutter project created with android/ ios/ lib/ directories.

**Step 2: Update pubspec.yaml dependencies**

Replace `pubspec.yaml` dependencies section with:

```yaml
name: matrix_terminal
description: A modern SSH client built with Flutter
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter
  # SSH
  dartssh2: ^2.13.0
  # Terminal
  xterm: ^4.0.0
  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  # Local database
  drift: ^2.22.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  # Secure storage
  flutter_secure_storage: ^9.2.4
  # Background service
  flutter_background_service: ^5.0.14
  flutter_local_notifications: ^18.0.1
  # Utils
  wakelock_plus: ^1.3.2
  uuid: ^4.5.1
  collection: ^1.19.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  drift_dev: ^2.22.1
  build_runner: ^2.4.14

flutter:
  uses-material-design: true
  fonts:
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
```

**Step 3: Install dependencies**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter pub get
```

Expected: All dependencies resolved successfully.

**Step 4: Create theme file**

Create `lib/app/theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0B133B);
  static const surface = Color(0xFF151E3F);
  static const primary = Color(0xFF6C63FF);
  static const textPrimary = Color(0xFFE8ECF4);
  static const textSecondary = Color(0xFF8890A6);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF5252);
  static const divider = Color(0xFF1E2A5E);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
```

**Step 5: Create app entry point**

Create `lib/app/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/features/host/screens/host_list_screen.dart';

class MatrixTerminalApp extends StatelessWidget {
  const MatrixTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Terminal',
      theme: AppTheme.dark,
      home: const HostListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MatrixTerminalApp(),
    ),
  );
}
```

**Step 6: Create placeholder host list screen**

Create `lib/features/host/screens/host_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';

class HostListScreen extends StatelessWidget {
  const HostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'No hosts yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dns),
            label: 'Hosts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key),
            label: 'Keychain',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

**Step 7: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

Expected: No analysis issues.

**Step 8: Commit**

```bash
git add -A
git commit -m "feat: scaffold Flutter project with theme and dependencies"
```

---

### Task 2: Database Layer (Drift)

**Files:**
- Create: `lib/core/storage/database.dart`
- Create: `lib/core/storage/database.g.dart` (generated)
- Create: `lib/core/storage/secure_store.dart`

**Step 1: Create Drift database with Host and HostGroup tables**

Create `lib/core/storage/database.dart`:

```dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class HostGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Hosts extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withLength(min: 1, max: 100)();
  TextColumn get hostname => text()();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get username => text()();
  TextColumn get groupId => text().nullable().references(HostGroups, #id)();
  TextColumn get authType => text().withDefault(const Constant('password'))();
  TextColumn get passwordRef => text().nullable()();
  TextColumn get privateKeyRef => text().nullable()();
  TextColumn get totpSecretRef => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Hosts, HostGroups])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 1;

  // Host CRUD
  Future<List<Host>> getAllHosts() => select(hosts).get();

  Stream<List<Host>> watchAllHosts() => select(hosts).watch();

  Stream<List<Host>> watchHostsByGroup(String groupId) {
    return (select(hosts)..where((h) => h.groupId.equals(groupId))).watch();
  }

  Stream<List<Host>> watchUngroupedHosts() {
    return (select(hosts)..where((h) => h.groupId.isNull())).watch();
  }

  Future<void> insertHost(HostsCompanion host) => into(hosts).insert(host);

  Future<void> updateHost(HostsCompanion host) =>
      (update(hosts)..where((h) => h.id.equals(host.id.value)))
          .write(host);

  Future<void> deleteHost(String id) =>
      (delete(hosts)..where((h) => h.id.equals(id))).go();

  Future<void> updateLastConnected(String id) =>
      (update(hosts)..where((h) => h.id.equals(id)))
          .write(HostsCompanion(lastConnectedAt: Value(DateTime.now())));

  // HostGroup CRUD
  Future<List<HostGroup>> getAllGroups() => select(hostGroups).get();

  Stream<List<HostGroup>> watchAllGroups() {
    return (select(hostGroups)
          ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
        .watch();
  }

  Future<void> insertGroup(HostGroupsCompanion group) =>
      into(hostGroups).insert(group);

  Future<void> updateGroup(HostGroupsCompanion group) =>
      (update(hostGroups)..where((g) => g.id.equals(group.id.value)))
          .write(group);

  Future<void> deleteGroup(String id) =>
      (delete(hostGroups)..where((g) => g.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'matrix_terminal.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**Step 2: Run code generation**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
dart run build_runner build --delete-conflicting-outputs
```

Expected: `database.g.dart` generated successfully.

**Step 3: Create secure storage wrapper**

Create `lib/core/storage/secure_store.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> read(String key) =>
      _storage.read(key: key);

  static Future<void> remove(String key) =>
      _storage.delete(key: key);

  static Future<void> removeAll() =>
      _storage.deleteAll();
}
```

**Step 4: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

Expected: No analysis issues.

**Step 5: Commit**

```bash
git add lib/core/storage/
git commit -m "feat: add Drift database and secure storage layer"
```

---

### Task 3: Riverpod Providers for Host & Group Management

**Files:**
- Create: `lib/features/host/providers/host_provider.dart`

**Step 1: Create host and group providers**

Create `lib/features/host/providers/host_provider.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final hostGroupsProvider = StreamProvider<List<HostGroup>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllGroups();
});

final allHostsProvider = StreamProvider<List<Host>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllHosts();
});

final hostsByGroupProvider =
    StreamProvider.family<List<Host>, String>((ref, groupId) {
  final db = ref.watch(databaseProvider);
  return db.watchHostsByGroup(groupId);
});

final ungroupedHostsProvider = StreamProvider<List<Host>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUngroupedHosts();
});

class HostNotifier {
  final AppDatabase _db;
  HostNotifier(this._db);

  Future<void> addHost({
    required String label,
    required String hostname,
    required int port,
    required String username,
    required String authType,
    String? groupId,
    String? password,
    String? privateKey,
    String? totpSecret,
  }) async {
    final id = _uuid.v4();
    String? passwordRef;
    String? privateKeyRef;
    String? totpSecretRef;

    if (password != null) {
      passwordRef = 'host_pwd_$id';
      await SecureStore.write(passwordRef, password);
    }
    if (privateKey != null) {
      privateKeyRef = 'host_key_$id';
      await SecureStore.write(privateKeyRef, privateKey);
    }
    if (totpSecret != null) {
      totpSecretRef = 'host_totp_$id';
      await SecureStore.write(totpSecretRef, totpSecret);
    }

    await _db.insertHost(HostsCompanion(
      id: Value(id),
      label: Value(label),
      hostname: Value(hostname),
      port: Value(port),
      username: Value(username),
      groupId: Value(groupId),
      authType: Value(authType),
      passwordRef: Value(passwordRef),
      privateKeyRef: Value(privateKeyRef),
      totpSecretRef: Value(totpSecretRef),
    ));
  }

  Future<void> updateHost({
    required String id,
    required String label,
    required String hostname,
    required int port,
    required String username,
    required String authType,
    String? groupId,
    String? password,
    String? privateKey,
    String? totpSecret,
  }) async {
    String? passwordRef;
    String? privateKeyRef;
    String? totpSecretRef;

    if (password != null) {
      passwordRef = 'host_pwd_$id';
      await SecureStore.write(passwordRef, password);
    }
    if (privateKey != null) {
      privateKeyRef = 'host_key_$id';
      await SecureStore.write(privateKeyRef, privateKey);
    }
    if (totpSecret != null) {
      totpSecretRef = 'host_totp_$id';
      await SecureStore.write(totpSecretRef, totpSecret);
    }

    await _db.updateHost(HostsCompanion(
      id: Value(id),
      label: Value(label),
      hostname: Value(hostname),
      port: Value(port),
      username: Value(username),
      groupId: Value(groupId),
      authType: Value(authType),
      passwordRef: Value(passwordRef),
      privateKeyRef: Value(privateKeyRef),
      totpSecretRef: Value(totpSecretRef),
    ));
  }

  Future<void> deleteHost(String id) async {
    await SecureStore.remove('host_pwd_$id');
    await SecureStore.remove('host_key_$id');
    await SecureStore.remove('host_totp_$id');
    await _db.deleteHost(id);
  }

  Future<void> addGroup(String name) async {
    await _db.insertGroup(HostGroupsCompanion(
      id: Value(_uuid.v4()),
      name: Value(name),
    ));
  }

  Future<void> deleteGroup(String id) async {
    await _db.deleteGroup(id);
  }
}

final hostNotifierProvider = Provider<HostNotifier>((ref) {
  return HostNotifier(ref.watch(databaseProvider));
});
```

**Step 2: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

Expected: No analysis issues.

**Step 3: Commit**

```bash
git add lib/features/host/providers/
git commit -m "feat: add Riverpod providers for host and group management"
```

---

### Task 4: Host List Screen (Termius-style UI)

**Files:**
- Modify: `lib/features/host/screens/host_list_screen.dart`
- Create: `lib/features/host/widgets/host_card.dart`
- Create: `lib/features/host/widgets/group_section.dart`

**Step 1: Create host card widget**

Create `lib/features/host/widgets/host_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';

class HostCard extends StatelessWidget {
  final Host host;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HostCard({
    super.key,
    required this.host,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initial = host.label.isNotEmpty ? host.label[0].toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    host.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${host.username}@${host.hostname}:${host.port}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.textPrimary),
              title: const Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Create group section widget**

Create `lib/features/host/widgets/group_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/widgets/host_card.dart';

class GroupSection extends StatefulWidget {
  final HostGroup group;
  final List<Host> hosts;
  final void Function(Host) onHostTap;
  final void Function(Host) onHostEdit;
  final void Function(Host) onHostDelete;

  const GroupSection({
    super.key,
    required this.group,
    required this.hosts,
    required this.onHostTap,
    required this.onHostEdit,
    required this.onHostDelete,
  });

  @override
  State<GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<GroupSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_more : Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.hosts.length}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.hosts.map((host) => HostCard(
                host: host,
                onTap: () => widget.onHostTap(host),
                onEdit: () => widget.onHostEdit(host),
                onDelete: () => widget.onHostDelete(host),
              )),
      ],
    );
  }
}
```

**Step 3: Update host list screen**

Replace `lib/features/host/screens/host_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';
import 'package:matrix_terminal/features/host/screens/host_edit_screen.dart';
import 'package:matrix_terminal/features/host/widgets/group_section.dart';
import 'package:matrix_terminal/features/host/widgets/host_card.dart';

class HostListScreen extends ConsumerStatefulWidget {
  const HostListScreen({super.key});

  @override
  ConsumerState<HostListScreen> createState() => _HostListScreenState();
}

class _HostListScreenState extends ConsumerState<HostListScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHostsTab(),
            _buildKeychainTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dns), label: 'Hosts'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Keychain'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildHostsTab() {
    final groupsAsync = ref.watch(hostGroupsProvider);
    final allHostsAsync = ref.watch(allHostsProvider);

    return Column(
      children: [
        // Search bar + add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search hosts...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, color: AppColors.primary),
                onPressed: _addGroup,
                tooltip: 'New Group',
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () => _navigateToEditHost(null),
                tooltip: 'New Host',
              ),
            ],
          ),
        ),
        // Host list
        Expanded(
          child: allHostsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allHosts) {
              final query = _searchController.text.toLowerCase();
              final filteredHosts = query.isEmpty
                  ? allHosts
                  : allHosts.where((h) =>
                      h.label.toLowerCase().contains(query) ||
                      h.hostname.toLowerCase().contains(query)).toList();

              return groupsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (groups) {
                  if (filteredHosts.isEmpty && groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dns_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hosts yet',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _navigateToEditHost(null),
                            child: const Text('Add your first host'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      // Grouped hosts
                      for (final group in groups) ...[
                        GroupSection(
                          group: group,
                          hosts: filteredHosts.where((h) => h.groupId == group.id).toList(),
                          onHostTap: _connectToHost,
                          onHostEdit: (h) => _navigateToEditHost(h),
                          onHostDelete: _deleteHost,
                        ),
                      ],
                      // Ungrouped hosts
                      ...filteredHosts
                          .where((h) => h.groupId == null)
                          .map((host) => HostCard(
                                host: host,
                                onTap: () => _connectToHost(host),
                                onEdit: () => _navigateToEditHost(host),
                                onDelete: () => _deleteHost(host),
                              )),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKeychainTab() {
    return const Center(
      child: Text('Keychain (Coming Soon)', style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Settings (Coming Soon)', style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  void _navigateToEditHost(Host? host) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HostEditScreen(host: host)),
    );
  }

  void _connectToHost(Host host) {
    // Will be implemented in Task 6 (Terminal Screen)
  }

  void _deleteHost(Host host) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Host', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${host.label}"?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(hostNotifierProvider).deleteHost(host.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _addGroup() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('New Group', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(hostNotifierProvider).addGroup(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
```

**Step 4: Create host edit screen**

Create `lib/features/host/screens/host_edit_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';

class HostEditScreen extends ConsumerStatefulWidget {
  final Host? host;

  const HostEditScreen({super.key, this.host});

  @override
  ConsumerState<HostEditScreen> createState() => _HostEditScreenState();
}

class _HostEditScreenState extends ConsumerState<HostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _hostnameCtrl;
  late final TextEditingController _portCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  String _authType = 'password';
  String? _selectedGroupId;

  bool get _isEditing => widget.host != null;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.host?.label ?? '');
    _hostnameCtrl = TextEditingController(text: widget.host?.hostname ?? '');
    _portCtrl = TextEditingController(text: (widget.host?.port ?? 22).toString());
    _usernameCtrl = TextEditingController(text: widget.host?.username ?? 'root');
    _passwordCtrl = TextEditingController();
    _authType = widget.host?.authType ?? 'password';
    _selectedGroupId = widget.host?.groupId;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _hostnameCtrl.dispose();
    _portCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(hostGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Host' : 'New Host'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField('Label', _labelCtrl, 'My Server'),
            const SizedBox(height: 16),
            _buildField('Hostname', _hostnameCtrl, '192.168.1.1'),
            const SizedBox(height: 16),
            _buildField('Port', _portCtrl, '22',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildField('Username', _usernameCtrl, 'root'),
            const SizedBox(height: 16),
            // Auth type selector
            const Text('Authentication',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'password', label: Text('Password')),
                ButtonSegment(value: 'privateKey', label: Text('Key')),
                ButtonSegment(value: 'totp', label: Text('TOTP')),
              ],
              selected: {_authType},
              onSelectionChanged: (v) => setState(() => _authType = v.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.white
                      : AppColors.textSecondary;
                }),
              ),
            ),
            const SizedBox(height: 16),
            if (_authType == 'password')
              _buildField('Password', _passwordCtrl, '',
                  obscure: true, required: !_isEditing),
            const SizedBox(height: 16),
            // Group selector
            groupsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (groups) {
                if (groups.isEmpty) return const SizedBox();
                return DropdownButtonFormField<String?>(
                  value: _selectedGroupId,
                  decoration: const InputDecoration(labelText: 'Group'),
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No group')),
                    ...groups.map((g) =>
                        DropdownMenuItem(value: g.id, child: Text(g.name))),
                  ],
                  onChanged: (v) => setState(() => _selectedGroupId = v),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(hostNotifierProvider);

    if (_isEditing) {
      notifier.updateHost(
        id: widget.host!.id,
        label: _labelCtrl.text.trim(),
        hostname: _hostnameCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text) ?? 22,
        username: _usernameCtrl.text.trim(),
        authType: _authType,
        groupId: _selectedGroupId,
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
      );
    } else {
      notifier.addHost(
        label: _labelCtrl.text.trim(),
        hostname: _hostnameCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text) ?? 22,
        username: _usernameCtrl.text.trim(),
        authType: _authType,
        groupId: _selectedGroupId,
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
      );
    }

    Navigator.pop(context);
  }
}
```

**Step 5: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

**Step 6: Commit**

```bash
git add lib/features/host/
git commit -m "feat: add host list, host edit, group section UI"
```

---

### Task 5: SSH Service Layer

**Files:**
- Create: `lib/core/ssh/ssh_service.dart`

**Step 1: Create SSH service**

Create `lib/core/ssh/ssh_service.dart`:

```dart
import 'dart:convert';
import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';
import 'package:xterm/xterm.dart' as xterm;

enum SessionState { connecting, connected, disconnected, error }

class SshSession {
  final String id;
  final Host host;
  final xterm.Terminal terminal;

  SSHClient? _client;
  SSHSession? _shell;
  SessionState state = SessionState.connecting;
  String? errorMessage;
  Timer? _keepAliveTimer;

  final _stateController = StreamController<SessionState>.broadcast();
  Stream<SessionState> get stateStream => _stateController.stream;

  SshSession({required this.id, required this.host})
      : terminal = xterm.Terminal(maxLines: 10000);

  Future<void> connect() async {
    try {
      state = SessionState.connecting;
      _stateController.add(state);

      final socket = await SSHSocket.connect(host.hostname, host.port);

      String? password;
      if (host.passwordRef != null) {
        password = await SecureStore.read(host.passwordRef!);
      }

      _client = SSHClient(
        socket,
        username: host.username,
        onPasswordRequest: () => password ?? '',
      );

      _shell = await _client!.shell(
        pty: SSHPtyConfig(
          width: terminal.viewWidth,
          height: terminal.viewHeight,
        ),
      );

      // Pipe SSH stdout to terminal
      _shell!.stdout.listen(
        (data) => terminal.write(utf8.decode(data, allowMalformed: true)),
        onDone: () {
          state = SessionState.disconnected;
          _stateController.add(state);
          _keepAliveTimer?.cancel();
        },
      );

      _shell!.stderr.listen(
        (data) => terminal.write(utf8.decode(data, allowMalformed: true)),
      );

      // Pipe terminal output (user keystrokes) to SSH
      terminal.onOutput = (data) {
        _shell?.write(utf8.encode(data));
      };

      // Handle terminal resize
      terminal.onResize = (width, height, pixelWidth, pixelHeight) {
        _shell?.resizeTerminal(width, height);
      };

      // Start keepalive
      _keepAliveTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) {
          try {
            _client?.sendIgnore();
          } catch (_) {}
        },
      );

      state = SessionState.connected;
      _stateController.add(state);
    } catch (e) {
      state = SessionState.error;
      errorMessage = e.toString();
      _stateController.add(state);
    }
  }

  /// Write raw text (from Chinese input bar) to the SSH channel
  void writeText(String text) {
    _shell?.write(utf8.encode(text));
  }

  void close() {
    _keepAliveTimer?.cancel();
    _shell?.close();
    _client?.close();
    state = SessionState.disconnected;
    _stateController.add(state);
    _stateController.close();
  }
}
```

**Step 2: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

**Step 3: Commit**

```bash
git add lib/core/ssh/
git commit -m "feat: add SSH service with dartssh2 connection and keepalive"
```

---

### Task 6: Session Manager (Riverpod)

**Files:**
- Create: `lib/features/terminal/providers/session_provider.dart`

**Step 1: Create session manager provider**

Create `lib/features/terminal/providers/session_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/core/ssh/ssh_service.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class SessionManagerState {
  final List<SshSession> sessions;
  final int activeIndex;

  const SessionManagerState({
    this.sessions = const [],
    this.activeIndex = 0,
  });

  SshSession? get activeSession =>
      sessions.isNotEmpty && activeIndex < sessions.length
          ? sessions[activeIndex]
          : null;

  SessionManagerState copyWith({
    List<SshSession>? sessions,
    int? activeIndex,
  }) {
    return SessionManagerState(
      sessions: sessions ?? this.sessions,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

class SessionManagerNotifier extends Notifier<SessionManagerState> {
  @override
  SessionManagerState build() => const SessionManagerState();

  Future<void> connect(Host host) async {
    final session = SshSession(id: _uuid.v4(), host: host);
    final newSessions = [...state.sessions, session];
    state = state.copyWith(
      sessions: newSessions,
      activeIndex: newSessions.length - 1,
    );

    await session.connect();

    // Update last connected time
    ref.read(databaseProvider).updateLastConnected(host.id);
  }

  void switchTo(int index) {
    if (index >= 0 && index < state.sessions.length) {
      state = state.copyWith(activeIndex: index);
    }
  }

  void closeSession(int index) {
    if (index < 0 || index >= state.sessions.length) return;

    state.sessions[index].close();
    final newSessions = [...state.sessions]..removeAt(index);
    int newIndex = state.activeIndex;

    if (newSessions.isEmpty) {
      newIndex = 0;
    } else if (index <= state.activeIndex && state.activeIndex > 0) {
      newIndex = state.activeIndex - 1;
    }

    state = state.copyWith(sessions: newSessions, activeIndex: newIndex);
  }

  void closeAll() {
    for (final session in state.sessions) {
      session.close();
    }
    state = const SessionManagerState();
  }
}

final sessionManagerProvider =
    NotifierProvider<SessionManagerNotifier, SessionManagerState>(
  SessionManagerNotifier.new,
);
```

**Step 2: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

**Step 3: Commit**

```bash
git add lib/features/terminal/providers/
git commit -m "feat: add session manager with multi-tab support"
```

---

### Task 7: Terminal Screen (Core UI)

**Files:**
- Create: `lib/features/terminal/screens/terminal_screen.dart`
- Create: `lib/features/terminal/widgets/terminal_toolbar.dart`
- Create: `lib/features/terminal/widgets/input_bar.dart`
- Create: `lib/features/terminal/widgets/session_tab_bar.dart`

**Step 1: Create terminal toolbar**

Create `lib/features/terminal/widgets/terminal_toolbar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';

class TerminalToolbar extends StatelessWidget {
  final void Function(String) onKey;

  const TerminalToolbar({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _btn('Esc', '\x1b'),
            _btn('Tab', '\t'),
            _btn('Ctrl', null, isModifier: true),
            _btn('Alt', null, isModifier: true),
            const SizedBox(width: 8),
            _btn('Up', '\x1b[A'),   // ↑
            _btn('Down', '\x1b[B'), // ↓
            _btn('Left', '\x1b[D'), // ←
            _btn('Right', '\x1b[C'),// →
            const SizedBox(width: 8),
            _btn('Home', '\x1b[H'),
            _btn('End', '\x1b[F'),
            _btn('PgUp', '\x1b[5~'),
            _btn('PgDn', '\x1b[6~'),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, String? seq, {bool isModifier = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: seq != null ? () => onKey(seq) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: isModifier ? AppColors.primary : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Create input bar (Chinese input support)**

Create `lib/features/terminal/widgets/input_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';

class InputBar extends StatefulWidget {
  final void Function(String text) onSubmit;

  const InputBar({super.key, required this.onSubmit});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Type here (supports Chinese)...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 3: Create session tab bar**

Create `lib/features/terminal/widgets/session_tab_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/ssh/ssh_service.dart';

class SessionTabBar extends StatelessWidget {
  final List<SshSession> sessions;
  final int activeIndex;
  final void Function(int) onTap;
  final void Function(int) onClose;
  final VoidCallback? onAdd;

  const SessionTabBar({
    super.key,
    required this.sessions,
    required this.activeIndex,
    required this.onTap,
    required this.onClose,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isActive = index == activeIndex;
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.surface : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _stateIcon(session.state),
                          size: 10,
                          color: _stateColor(session.state),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.host.label,
                          style: TextStyle(
                            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onClose(index),
                          child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add, size: 18, color: AppColors.textSecondary),
              onPressed: onAdd,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36),
            ),
        ],
      ),
    );
  }

  IconData _stateIcon(SessionState state) {
    return switch (state) {
      SessionState.connecting => Icons.hourglass_top,
      SessionState.connected => Icons.circle,
      SessionState.disconnected => Icons.circle_outlined,
      SessionState.error => Icons.error,
    };
  }

  Color _stateColor(SessionState state) {
    return switch (state) {
      SessionState.connecting => AppColors.textSecondary,
      SessionState.connected => AppColors.success,
      SessionState.disconnected => AppColors.textSecondary,
      SessionState.error => AppColors.error,
    };
  }
}
```

**Step 4: Create terminal screen**

Create `lib/features/terminal/screens/terminal_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/ssh/ssh_service.dart';
import 'package:matrix_terminal/features/terminal/providers/session_provider.dart';
import 'package:matrix_terminal/features/terminal/widgets/input_bar.dart';
import 'package:matrix_terminal/features/terminal/widgets/session_tab_bar.dart';
import 'package:matrix_terminal/features/terminal/widgets/terminal_toolbar.dart';
import 'package:xterm/xterm.dart' as xterm;

class TerminalScreen extends ConsumerWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionManagerProvider);
    final sessions = sessionState.sessions;
    final activeSession = sessionState.activeSession;

    if (sessions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('No sessions', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar
            SessionTabBar(
              sessions: sessions,
              activeIndex: sessionState.activeIndex,
              onTap: (i) => ref.read(sessionManagerProvider.notifier).switchTo(i),
              onClose: (i) {
                ref.read(sessionManagerProvider.notifier).closeSession(i);
                if (ref.read(sessionManagerProvider).sessions.isEmpty) {
                  Navigator.pop(context);
                }
              },
            ),
            // Toolbar
            TerminalToolbar(
              onKey: (seq) => activeSession?.writeText(seq),
            ),
            // Terminal view
            Expanded(
              child: IndexedStack(
                index: sessionState.activeIndex,
                children: sessions.map((session) {
                  return xterm.TerminalView(
                    session.terminal,
                    style: const xterm.TerminalStyle(
                      fontSize: 14,
                      fontFamily: 'JetBrainsMono',
                    ),
                  );
                }).toList(),
              ),
            ),
            // Input bar (Chinese input support)
            InputBar(
              onSubmit: (text) => activeSession?.writeText(text),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Wire up host list to terminal screen**

In `lib/features/host/screens/host_list_screen.dart`, update the `_connectToHost` method:

```dart
// Add imports at top:
import 'package:matrix_terminal/features/terminal/providers/session_provider.dart';
import 'package:matrix_terminal/features/terminal/screens/terminal_screen.dart';

// Replace _connectToHost method:
void _connectToHost(Host host) {
  ref.read(sessionManagerProvider.notifier).connect(host);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TerminalScreen()),
  );
}
```

**Step 6: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

**Step 7: Commit**

```bash
git add lib/features/terminal/ lib/features/host/screens/host_list_screen.dart
git commit -m "feat: add terminal screen with tab bar, toolbar, and Chinese input bar"
```

---

### Task 8: Background Service (Keep-Alive)

**Files:**
- Create: `lib/core/background/background_service.dart`
- Modify: `lib/main.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Step 1: Configure Android permissions**

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>` (before `<application>`):

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

Add `android:foregroundServiceType="dataSync"` to the `<service>` tag if it exists, or add:

```xml
<service
    android:name="id.flutter.flutter_background_service.BackgroundService"
    android:foregroundServiceType="dataSync" />
```

inside `<application>`.

**Step 2: Create background service**

Create `lib/core/background/background_service.dart`:

```dart
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BackgroundServiceManager {
  static final _service = FlutterBackgroundService();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const channel = AndroidNotificationChannel(
      'matrix_terminal_fg',
      'Matrix Terminal',
      description: 'Keeps SSH connections alive',
      importance: Importance.low,
    );

    final flnp = FlutterLocalNotificationsPlugin();
    await flnp
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'matrix_terminal_fg',
        initialNotificationTitle: 'Matrix Terminal',
        initialNotificationContent: 'SSH connections active',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
    );

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((_) {
        service.setAsBackgroundService();
      });
    }
    service.on('stopService').listen((_) {
      service.stopSelf();
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }

  static Future<void> startService(int sessionCount) async {
    await init();
    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
      await WakelockPlus.enable();
    }
  }

  static Future<void> stopService() async {
    _service.invoke('stopService');
    await WakelockPlus.disable();
  }

  static Future<void> updateNotification(int sessionCount) async {
    // Notification content is updated via the service
  }
}
```

**Step 3: Integrate with session manager**

In `lib/features/terminal/providers/session_provider.dart`, add background service calls:

Add import:
```dart
import 'package:matrix_terminal/core/background/background_service.dart';
```

In `connect()` method, after `await session.connect();` add:
```dart
await BackgroundServiceManager.startService(state.sessions.length);
```

In `closeSession()` method, after updating state, add:
```dart
if (state.sessions.isEmpty) {
  BackgroundServiceManager.stopService();
}
```

In `closeAll()` method, add:
```dart
BackgroundServiceManager.stopService();
```

**Step 4: Verify build**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/core/background/ lib/features/terminal/providers/ android/
git commit -m "feat: add background service for SSH keep-alive"
```

---

### Task 9: Download Font & Final Integration

**Files:**
- Create: `assets/fonts/JetBrainsMono-Regular.ttf`
- Modify: `lib/main.dart` (final wiring)

**Step 1: Download JetBrains Mono font**

Run:
```bash
mkdir -p /Volumes/mac-extra/github/matrix/assets/fonts
cd /Volumes/mac-extra/github/matrix/assets/fonts
curl -L -o JetBrainsMono.zip "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
unzip -j JetBrainsMono.zip "fonts/ttf/JetBrainsMono-Regular.ttf" -d .
rm JetBrainsMono.zip
```

Expected: `JetBrainsMono-Regular.ttf` in assets/fonts/.

**Step 2: Final main.dart**

Ensure `lib/main.dart` has background service init:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/app.dart';
import 'package:matrix_terminal/core/background/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundServiceManager.init();
  runApp(
    const ProviderScope(
      child: MatrixTerminalApp(),
    ),
  );
}
```

**Step 3: Full build verification**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter analyze
flutter build apk --debug
```

Expected: APK builds successfully.

**Step 4: Commit**

```bash
git add assets/ lib/main.dart
git commit -m "feat: add font assets and finalize app integration"
```

---

### Task 10: Build Release APK

**Step 1: Build release APK**

Run:
```bash
cd /Volumes/mac-extra/github/matrix
flutter build apk --release
```

Expected: APK at `build/app/outputs/flutter-apk/app-release.apk`.

**Step 2: Final commit**

```bash
git add -A
git commit -m "chore: release-ready Matrix Terminal v1.0.0"
```
