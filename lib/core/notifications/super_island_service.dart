import 'dart:convert';
import 'package:flutter/services.dart';

/// Xiaomi HyperOS Super Island (超级岛) integration.
///
/// On supported devices (HyperOS 1/2/3), notifications are displayed
/// as Dynamic Island-style pills. On unsupported devices, returns false
/// so callers can fall back to standard notifications.
class SuperIslandService {
  static const _channel = MethodChannel('com.matrix.terminal/super_island');
  static int? _cachedVersion;

  /// Returns the Super Island protocol version.
  /// 0 = not supported, 1 = OS1, 2 = OS2, 3 = OS3.
  static Future<int> getVersion() async {
    if (_cachedVersion != null) return _cachedVersion!;
    try {
      final version =
          await _channel.invokeMethod<int>('getSuperIslandVersion');
      _cachedVersion = version ?? 0;
      return _cachedVersion!;
    } on PlatformException {
      _cachedVersion = 0;
      return 0;
    }
  }

  /// Returns true if the device supports Super Island.
  static Future<bool> get isSupported async => (await getVersion()) > 0;

  /// Show a connection status notification as Super Island.
  /// Returns true if shown as island, false if not supported.
  static Future<bool> showConnectionNotification({
    required int notificationId,
    required String title,
    required String body,
    required String hostname,
    required String status, // 'connected', 'disconnected', 'error'
  }) async {
    if (!(await isSupported)) return false;

    final focusParam = _buildConnectionFocusParam(
      hostname: hostname,
      status: status,
      title: title,
      body: body,
    );

    try {
      await _channel.invokeMethod('showIslandNotification', {
        'channelId': 'connection_status',
        'channelName': 'Connection Status',
        'title': title,
        'body': body,
        'notificationId': notificationId,
        'focusParam': jsonEncode(focusParam),
        'importance': 4, // IMPORTANCE_HIGH
      });
      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Show a command completion notification as Super Island.
  /// Returns true if shown as island, false if not supported.
  static Future<bool> showCommandNotification({
    required int notificationId,
    required String title,
    required String body,
    required String hostname,
  }) async {
    if (!(await isSupported)) return false;

    final focusParam = _buildCommandFocusParam(
      hostname: hostname,
      title: title,
      body: body,
    );

    try {
      await _channel.invokeMethod('showIslandNotification', {
        'channelId': 'command_alerts',
        'channelName': 'Command Alerts',
        'title': title,
        'body': body,
        'notificationId': notificationId,
        'focusParam': jsonEncode(focusParam),
        'importance': 3, // IMPORTANCE_DEFAULT
      });
      return true;
    } on PlatformException {
      return false;
    }
  }

  static Map<String, dynamic> _buildConnectionFocusParam({
    required String hostname,
    required String status,
    required String title,
    required String body,
  }) {
    final statusIcon = switch (status) {
      'connected' => '🟢',
      'disconnected' => '🔴',
      'error' => '⚠️',
      _ => '●',
    };

    return {
      'param_v2': {
        'business': 'ssh_connection',
        'ticker': '$statusIcon $hostname - $title',
        'param_island': {
          'islandProperty': 1, // information display
          'timeout': 30, // minutes
          'updatable': true,
          'smallIslandArea': {
            'text': '$statusIcon $hostname',
          },
          'bigIslandArea': {
            'title': hostname,
            'subTitle': body,
            'desc': 'SSH $status',
          },
        },
        'baseInfo': {
          'title': title,
          'content': body,
        },
        'aodTitle': '$hostname $title',
      },
    };
  }

  static Map<String, dynamic> _buildCommandFocusParam({
    required String hostname,
    required String title,
    required String body,
  }) {
    return {
      'param_v2': {
        'business': 'ssh_command',
        'ticker': '✅ $hostname - $title',
        'param_island': {
          'islandProperty': 1,
          'timeout': 10,
          'updatable': false,
          'smallIslandArea': {
            'text': '✅ $hostname',
          },
          'bigIslandArea': {
            'title': hostname,
            'subTitle': body,
            'desc': 'Command completed',
          },
        },
        'baseInfo': {
          'title': title,
          'content': body,
        },
        'aodTitle': '$hostname: $title',
      },
    };
  }
}
