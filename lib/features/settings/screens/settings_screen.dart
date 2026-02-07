import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';

/// Terminal font size setting, persisted via Riverpod.
final fontSizeProvider = StateProvider<double>((ref) => 14.0);

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
