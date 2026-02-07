import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/storage/database.dart';
import 'package:matrix_terminal/features/host/providers/host_provider.dart';
import 'package:matrix_terminal/features/host/screens/host_edit_screen.dart';
import 'package:matrix_terminal/features/host/widgets/group_section.dart';
import 'package:matrix_terminal/features/host/widgets/host_card.dart';
import 'package:matrix_terminal/features/terminal/providers/session_provider.dart';
import 'package:matrix_terminal/features/terminal/screens/terminal_screen.dart';

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
          BottomNavigationBarItem(
              icon: Icon(Icons.vpn_key), label: 'Keychain'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildHostsTab() {
    final groupsAsync = ref.watch(hostGroupsProvider);
    final allHostsAsync = ref.watch(allHostsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search hosts...',
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textSecondary),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined,
                    color: AppColors.primary),
                onPressed: _addGroup,
                tooltip: 'New Group',
              ),
              IconButton(
                icon: const Icon(Icons.add_circle,
                    color: AppColors.primary),
                onPressed: () => _navigateToEditHost(null),
                tooltip: 'New Host',
              ),
            ],
          ),
        ),
        Expanded(
          child: allHostsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allHosts) {
              final query = _searchController.text.toLowerCase();
              final filteredHosts = query.isEmpty
                  ? allHosts
                  : allHosts
                      .where((h) =>
                          h.label.toLowerCase().contains(query) ||
                          h.hostname.toLowerCase().contains(query))
                      .toList();

              return groupsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (groups) {
                  if (filteredHosts.isEmpty && groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dns_outlined,
                              size: 64,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'No hosts yet',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                _navigateToEditHost(null),
                            child: const Text('Add your first host'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      for (final group in groups) ...[
                        GroupSection(
                          group: group,
                          hosts: filteredHosts
                              .where((h) => h.groupId == group.id)
                              .toList(),
                          onHostTap: _connectToHost,
                          onHostEdit: (h) => _navigateToEditHost(h),
                          onHostDelete: _deleteHost,
                        ),
                      ],
                      ...filteredHosts
                          .where((h) => h.groupId == null)
                          .map((host) => HostCard(
                                host: host,
                                onTap: () => _connectToHost(host),
                                onEdit: () =>
                                    _navigateToEditHost(host),
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
      child: Text('Keychain (Coming Soon)',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Settings (Coming Soon)',
          style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  void _navigateToEditHost(Host? host) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HostEditScreen(host: host)),
    );
  }

  void _connectToHost(Host host) {
    ref.read(sessionManagerProvider.notifier).connect(host);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TerminalScreen()),
    );
  }

  void _deleteHost(Host host) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Host',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${host.label}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
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
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
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
        title: const Text('New Group',
            style: TextStyle(color: AppColors.textPrimary)),
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
