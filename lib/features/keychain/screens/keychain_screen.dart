import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/secure_store.dart';

/// Manages a list of SSH key names stored as a comma-separated string.
final _keyListProvider =
    StateNotifierProvider<_KeyListNotifier, List<String>>((ref) {
  return _KeyListNotifier();
});

class _KeyListNotifier extends StateNotifier<List<String>> {
  static const _indexKey = 'ssh_key_index';

  _KeyListNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final index = await SecureStore.read(_indexKey);
    if (index != null && index.isNotEmpty) {
      state = index.split(',');
    }
  }

  Future<void> _saveIndex() async {
    await SecureStore.write(_indexKey, state.join(','));
  }

  Future<void> addKey(String name, String pem) async {
    await SecureStore.write('sshkey_$name', pem);
    state = [...state, name];
    await _saveIndex();
  }

  Future<void> removeKey(String name) async {
    await SecureStore.remove('sshkey_$name');
    state = state.where((n) => n != name).toList();
    await _saveIndex();
  }

  Future<String?> getKeyPem(String name) async {
    return SecureStore.read('sshkey_$name');
  }
}

class KeychainScreen extends ConsumerWidget {
  const KeychainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = ref.watch(_keyListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'SSH Keys',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () => _showImportDialog(context, ref),
                tooltip: 'Import Key',
              ),
            ],
          ),
        ),
        if (keys.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vpn_key_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No SSH keys',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showImportDialog(context, ref),
                    child: const Text('Import your first key'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final name = keys[index];
                return _KeyTile(
                  name: name,
                  onView: () => _viewKey(context, ref, name),
                  onDelete: () => _confirmDelete(context, ref, name),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final pemCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Import SSH Key',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Key Name',
                  hintText: 'my-server-key',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pemCtrl,
                maxLines: 6,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                ),
                decoration: const InputDecoration(
                  labelText: 'Private Key (PEM)',
                  hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final pem = pemCtrl.text.trim();
              if (name.isNotEmpty && pem.isNotEmpty) {
                ref.read(_keyListProvider.notifier).addKey(name, pem);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewKey(
      BuildContext context, WidgetRef ref, String name) async {
    final pem = await ref.read(_keyListProvider.notifier).getKeyPem(name);
    if (!context.mounted || pem == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: SelectableText(
            pem,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pem));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Key',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "$name"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(_keyListProvider.notifier).removeKey(name);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _KeyTile extends StatelessWidget {
  final String name;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _KeyTile({
    required this.name,
    required this.onView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0x336C63FF),
        child: Icon(Icons.vpn_key, color: AppColors.primary, size: 20),
      ),
      title: Text(name,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      subtitle: const Text('SSH Private Key',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon:
                const Icon(Icons.visibility, color: AppColors.textSecondary, size: 20),
            onPressed: onView,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
