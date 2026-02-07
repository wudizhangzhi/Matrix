import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';

class TerminalToolbar extends StatelessWidget {
  final void Function(String) onKey;

  const TerminalToolbar({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _btn('Esc', '\x1b'),
            _btn('Tab', '\t'),
            const SizedBox(width: 8),
            _btn('Up', '\x1b[A'),
            _btn('Down', '\x1b[B'),
            _btn('Left', '\x1b[D'),
            _btn('Right', '\x1b[C'),
            const SizedBox(width: 8),
            _btn('Home', '\x1b[H'),
            _btn('End', '\x1b[F'),
            _btn('PgUp', '\x1b[5~'),
            _btn('PgDn', '\x1b[6~'),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, String seq) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onKey(seq),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
