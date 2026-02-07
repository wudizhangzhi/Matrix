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
            _btn('Enter', '\r', highlight: true),
            _btn('Esc', '\x1b'),
            _btn('Tab', '\t'),
            _btn('Ctrl-C', '\x03'),
            const SizedBox(width: 8),
            _btn('\u2190', '\x1b[D'),
            _btn('\u2192', '\x1b[C'),
            _btn('\u2191', '\x1b[A'),
            _btn('\u2193', '\x1b[B'),
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

  Widget _btn(String label, String seq, {bool highlight = false}) {
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
              style: TextStyle(
                color: highlight ? AppColors.primary : AppColors.textPrimary,
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
