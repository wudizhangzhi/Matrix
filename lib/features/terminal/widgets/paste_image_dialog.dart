import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/clipboard/clipboard_service.dart';

/// Shows a confirmation dialog for pasting clipboard image as base64.
/// Returns the text to paste, or null if cancelled.
Future<String?> showPasteImageDialog(
    BuildContext context, Uint8List imageBytes) {
  final sizeKb = (imageBytes.length / 1024).toStringAsFixed(1);
  final base64Size = ((imageBytes.length * 4 / 3) / 1024).toStringAsFixed(1);

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Paste Image',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              imageBytes,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Image: $sizeKb KB\nBase64 output: ~$base64Size KB',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if (imageBytes.length > 512 * 1024)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Large image - may be slow to paste',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final cmd = ClipboardImageService.toShellCommand(imageBytes);
            Navigator.pop(ctx, cmd);
          },
          child: const Text('As Command'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx, ClipboardImageService.toBase64(imageBytes));
          },
          child: const Text('Raw Base64'),
        ),
      ],
    ),
  );
}
