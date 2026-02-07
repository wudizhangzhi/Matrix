import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/core/background/background_service.dart';
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

    // Start background service to keep connections alive
    await BackgroundServiceManager.startService(state.sessions.length);
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

    if (state.sessions.isEmpty) {
      BackgroundServiceManager.stopService();
    }
  }

  void closeAll() {
    for (final session in state.sessions) {
      session.close();
    }
    state = const SessionManagerState();
    BackgroundServiceManager.stopService();
  }
}

final sessionManagerProvider =
    NotifierProvider<SessionManagerNotifier, SessionManagerState>(
  SessionManagerNotifier.new,
);
