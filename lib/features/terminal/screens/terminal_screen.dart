import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/ssh/ssh_service.dart';
import 'package:matrix_terminal/features/settings/screens/settings_screen.dart';
import 'package:matrix_terminal/features/terminal/providers/session_provider.dart';
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
    final fontSize = ref.watch(fontSizeProvider);

    if (sessions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
            child: Text('No sessions',
                style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SessionTabBar(
              sessions: sessions,
              activeIndex: sessionState.activeIndex,
              onTap: (i) =>
                  ref.read(sessionManagerProvider.notifier).switchTo(i),
              onClose: (i) {
                ref.read(sessionManagerProvider.notifier).closeSession(i);
                if (ref.read(sessionManagerProvider).sessions.isEmpty) {
                  Navigator.pop(context);
                }
              },
            ),
            Expanded(
              child: IndexedStack(
                index: sessionState.activeIndex,
                children: sessions.map((session) {
                  return Stack(
                    children: [
                      xterm.TerminalView(
                        session.terminal,
                        textStyle: xterm.TerminalStyle(
                          fontSize: fontSize,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                      _ConnectionOverlay(
                        session: session,
                        onRetry: () async {
                          await session.connect();
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            TerminalToolbar(
              onKey: (seq) => activeSession?.writeText(seq),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionOverlay extends StatefulWidget {
  final SshSession session;
  final VoidCallback onRetry;

  const _ConnectionOverlay({
    required this.session,
    required this.onRetry,
  });

  @override
  State<_ConnectionOverlay> createState() => _ConnectionOverlayState();
}

class _ConnectionOverlayState extends State<_ConnectionOverlay> {
  late SessionState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.session.state;
    widget.session.stateStream.listen((state) {
      if (mounted) setState(() => _state = state);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state == SessionState.connected) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: AppColors.background.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_state == SessionState.connecting) ...[
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Connecting...',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.session.host.username}@${widget.session.host.hostname}:${widget.session.host.port}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
              if (_state == SessionState.error) ...[
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Connection Failed',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.session.errorMessage ?? 'Unknown error',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
              if (_state == SessionState.disconnected) ...[
                const Icon(Icons.link_off,
                    color: AppColors.textSecondary, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Disconnected',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reconnect'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
