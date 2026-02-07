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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activeId > 0)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                      onPressed: () => _showKeyCatalog(context),
                      tooltip: 'Add Key',
                    ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: () => _createNewProfile(context),
                    tooltip: 'New Profile',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const Text(
            'BUTTONS',
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
    if (seq == '\x1b') return 'Escape';
    if (seq == '\t') return 'Tab';
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

    final activeId = ref.read(activeToolbarProfileIdProvider);
    if (activeId == id) {
      ref.read(activeToolbarProfileIdProvider.notifier).state = -1;
      await ToolbarProfileService.saveActiveProfileId(-1);
    }
  }

  void _showKeyCatalog(BuildContext context) {
    final buttons = ref.read(activeToolbarButtonsProvider);
    final activeId = ref.read(activeToolbarProfileIdProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (_) => KeyCatalogPicker(
        profileId: activeId,
        currentButtons: buttons,
      ),
    );
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
