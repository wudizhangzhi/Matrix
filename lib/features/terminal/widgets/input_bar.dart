import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';

class InputBar extends StatefulWidget {
  final void Function(String text) onSubmit;

  const InputBar({super.key, required this.onSubmit});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
    }
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'JetBrainsMono',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Type here (supports Chinese)...',
                  hintStyle: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}
