import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/ssh/ssh_service.dart';

class SessionTabBar extends StatelessWidget {
  final List<SshSession> sessions;
  final int activeIndex;
  final void Function(int) onTap;
  final void Function(int) onClose;
  final VoidCallback? onAdd;

  const SessionTabBar({
    super.key,
    required this.sessions,
    required this.activeIndex,
    required this.onTap,
    required this.onClose,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isActive = index == activeIndex;
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.surface : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isActive
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _stateIcon(session.state),
                          size: 10,
                          color: _stateColor(session.state),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          session.host.label,
                          style: TextStyle(
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onClose(index),
                          child: const Icon(Icons.close,
                              size: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add,
                  size: 18, color: AppColors.textSecondary),
              onPressed: onAdd,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36),
            ),
        ],
      ),
    );
  }

  IconData _stateIcon(SessionState state) {
    return switch (state) {
      SessionState.connecting => Icons.hourglass_top,
      SessionState.connected => Icons.circle,
      SessionState.disconnected => Icons.circle_outlined,
      SessionState.error => Icons.error,
    };
  }

  Color _stateColor(SessionState state) {
    return switch (state) {
      SessionState.connecting => AppColors.textSecondary,
      SessionState.connected => AppColors.success,
      SessionState.disconnected => AppColors.textSecondary,
      SessionState.error => AppColors.error,
    };
  }
}
