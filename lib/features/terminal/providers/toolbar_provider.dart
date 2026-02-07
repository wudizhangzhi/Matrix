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
final customToolbarProfilesProvider =
    StreamProvider<List<ToolbarProfile>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllToolbarProfiles();
});

/// Represents a resolved toolbar profile with its buttons.
class ResolvedToolbarProfile {
  final int id;
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
final allToolbarProfilesProvider =
    Provider<AsyncValue<List<ResolvedToolbarProfile>>>((ref) {
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

final savedProfileIdProvider = FutureProvider<int>((ref) async {
  return ToolbarProfileService.loadActiveProfileId();
});
