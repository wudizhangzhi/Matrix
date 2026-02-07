import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ClipboardImageService {
  static const _channel = MethodChannel('com.matrix.terminal/clipboard');

  /// Returns image bytes from clipboard, or null if no image.
  static Future<Uint8List?> getClipboardImage() async {
    try {
      final result =
          await _channel.invokeMethod<Uint8List>('getClipboardImage');
      return result;
    } on PlatformException {
      return null;
    }
  }

  /// Returns true if clipboard contains an image.
  static Future<bool> hasClipboardImage() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasClipboardImage');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Convert image bytes to base64 string.
  static String toBase64(Uint8List bytes) => base64Encode(bytes);

  /// Format as a shell command that decodes base64 to a file.
  static String toShellCommand(Uint8List bytes,
      {String path = '/tmp/clipboard.png'}) {
    final b64 = base64Encode(bytes);
    return "echo '$b64' | base64 -d > $path";
  }
}
