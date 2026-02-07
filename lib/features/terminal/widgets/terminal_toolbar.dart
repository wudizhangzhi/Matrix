import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix_terminal/app/theme.dart';
import 'package:matrix_terminal/core/clipboard/clipboard_service.dart';
import 'package:matrix_terminal/features/terminal/models/toolbar_button.dart';
import 'package:matrix_terminal/features/terminal/providers/toolbar_provider.dart';
import 'package:matrix_terminal/features/terminal/widgets/paste_image_dialog.dart';

class TerminalToolbar extends ConsumerWidget {
  final void Function(String) onKey;
  final VoidCallback? onOpenEditor;

  const TerminalToolbar({super.key, required this.onKey, this.onOpenEditor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttons = ref.watch(activeToolbarButtonsProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buttons.map((btn) => _buildBtn(btn)).toList(),
              ),
            ),
          ),
          _imageBtn(context),
          _gearBtn(),
        ],
      ),
    );
  }

  Widget _buildBtn(ToolbarButton btn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onKey(btn.sequence),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              btn.label,
              style: TextStyle(
                color: btn.highlight ? AppColors.primary : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _showImageOptions(context),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.image_outlined,
                color: AppColors.textSecondary, size: 18),
          ),
        ),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Pick from Gallery',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_paste,
                  color: AppColors.primary),
              title: const Text('Paste from Clipboard',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _handleClipboardPaste(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (bytes.length > 2 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large (max 2MB)')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final result = await showPasteImageDialog(context, bytes);
    if (result != null) {
      onKey(result);
    }
  }

  Future<void> _handleClipboardPaste(BuildContext context) async {
    final imageBytes = await ClipboardImageService.getClipboardImage();
    if (imageBytes == null) {
      final textData = await Clipboard.getData(Clipboard.kTextPlain);
      if (textData?.text != null) {
        onKey(textData!.text!);
      }
      return;
    }

    if (imageBytes.length > 2 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large (max 2MB)')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final result = await showPasteImageDialog(context, imageBytes);
    if (result != null) {
      onKey(result);
    }
  }

  Widget _gearBtn() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onOpenEditor,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child:
                Icon(Icons.settings, color: AppColors.textSecondary, size: 18),
          ),
        ),
      ),
    );
  }
}
