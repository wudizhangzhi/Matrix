import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/notifications/terminal_monitor.dart';
import 'package:matrix_terminal/core/notifications/notification_service.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';

/// Terminal font size setting, persisted via Riverpod.
final fontSizeProvider = StateProvider<double>((ref) => 14.0);

final connectionNotifProvider = StateProvider<bool>((ref) => true);
final commandNotifProvider = StateProvider<bool>((ref) => true);

final notificationPatternsProvider =
    StreamProvider<List<NotificationPattern>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchNotificationPatterns();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // Terminal section
        const Text(
          'TERMINAL',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Font Size',
                        style: TextStyle(color: AppColors.textPrimary)),
                    Text(
                      '${fontSize.toInt()} px',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Slider(
                  value: fontSize,
                  min: 8,
                  max: 24,
                  divisions: 16,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.divider,
                  onChanged: (v) =>
                      ref.read(fontSizeProvider.notifier).state = v,
                ),
                // Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'user@server:~\$ ls -la\ndrwxr-xr-x  2 user user 4096 Feb  7 12:00 .',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'JetBrainsMono',
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

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
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                value: ref.watch(connectionNotifProvider),
                activeColor: AppColors.primary,
                onChanged: (v) async {
                  ref.read(connectionNotifProvider.notifier).state = v;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(
                      TerminalMonitor.keyConnectionNotif, v);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Command Completion',
                    style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Notify when commands finish',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
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
                leading: const Icon(Icons.notifications_active,
                    color: AppColors.primary),
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
              icon:
                  const Icon(Icons.add, color: AppColors.primary, size: 20),
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
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                            subtitle: Text(
                                'Tap + to add a regex pattern trigger',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ),
                        ]
                      : patterns
                          .map((p) => ListTile(
                                title: Text(p.title,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary)),
                                subtitle: Text(p.pattern,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 11)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.error, size: 20),
                                  onPressed: () {
                                    ref
                                        .read(databaseProvider)
                                        .deleteNotificationPattern(p.id);
                                  },
                                ),
                              ))
                          .toList(),
                ),
              ),
            ),

        const SizedBox(height: 24),

        // About section
        const Text(
          'ABOUT',
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
              ListTile(
                title: const Text('Version',
                    style: TextStyle(color: AppColors.textPrimary)),
                trailing: const Text('1.0.0',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Matrix Terminal',
                    style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text(
                  'A modern SSH client with Chinese input support',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Danger zone
        const Text(
          'DATA',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading:
                const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Clear All Data',
                style: TextStyle(color: AppColors.error)),
            subtitle: const Text(
              'Remove all hosts, keys, and settings',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            onTap: () => _confirmClearData(context, ref),
          ),
        ),
      ],
    );
  }

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
                  patternCtrl.text.trim().isEmpty) {
                return;
              }
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

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear All Data',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will delete all hosts, SSH keys, and settings. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await SecureStore.removeAll();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
