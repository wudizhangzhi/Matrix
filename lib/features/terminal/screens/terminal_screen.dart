import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_terminal/app/theme.dart';
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
            TerminalToolbar(
              onKey: (seq) => activeSession?.writeText(seq),
            ),
            Expanded(
              child: IndexedStack(
                index: sessionState.activeIndex,
                children: sessions.map((session) {
                  return xterm.TerminalView(
                    session.terminal,
                    textStyle: const xterm.TerminalStyle(
                      fontSize: 14,
                      fontFamily: 'JetBrainsMono',
                    ),
                  );
                }).toList(),
              ),
            ),
            InputBar(
              onSubmit: (text) => activeSession?.writeText(text),
            ),
          ],
        ),
      ),
    );
  }
}
