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

  static const keyConnectionNotif = 'notif_connection';
  static const keyCommandNotif = 'notif_command';
  static const keyPromptPattern = 'notif_prompt_pattern';

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
            hostname: hostLabel,
            status: 'disconnected',
          );
        } else if (state == SessionState.connected &&
            previousState != SessionState.connected) {
          await NotificationService.showConnectionNotification(
            title: 'Connected',
            body: '$hostLabel is now connected',
            hostname: hostLabel,
            status: 'connected',
          );
        } else if (state == SessionState.error) {
          await NotificationService.showConnectionNotification(
            title: 'Connection Error',
            body: '$hostLabel: ${session.errorMessage ?? "Unknown error"}',
            hostname: hostLabel,
            status: 'error',
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
  Future<void> checkOutput({
    required String text,
    required String hostLabel,
    required List<NotificationPattern> patterns,
  }) async {
    if (!_isBackground) return;

    final prefs = await SharedPreferences.getInstance();

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
            hostname: hostLabel,
          );
        }
      } catch (_) {
        // Invalid regex, skip
      }
    }

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
