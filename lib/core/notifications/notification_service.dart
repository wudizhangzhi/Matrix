import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix_terminal/core/notifications/super_island_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _notificationId = 100;

  static const _connectionChannel = AndroidNotificationChannel(
    'connection_status',
    'Connection Status',
    description: 'SSH connection state changes',
    importance: Importance.high,
  );

  static const _commandChannel = AndroidNotificationChannel(
    'command_alerts',
    'Command Alerts',
    description: 'Command completion notifications',
    importance: Importance.defaultImportance,
  );

  static const _customChannel = AndroidNotificationChannel(
    'custom_triggers',
    'Custom Triggers',
    description: 'Custom pattern match notifications',
    importance: Importance.defaultImportance,
  );

  static Future<void> init() async {
    if (_initialized) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_connectionChannel);
    await androidPlugin?.createNotificationChannel(_commandChannel);
    await androidPlugin?.createNotificationChannel(_customChannel);

    _initialized = true;
  }

  /// Show a connection status notification.
  /// Tries Super Island first on Xiaomi devices, falls back to standard.
  static Future<void> showConnectionNotification({
    required String title,
    required String body,
    String? hostname,
    String? status,
  }) async {
    await init();
    final id = _notificationId++;

    // Try Super Island on Xiaomi HyperOS
    if (hostname != null && status != null) {
      final shown = await SuperIslandService.showConnectionNotification(
        notificationId: id,
        title: title,
        body: body,
        hostname: hostname,
        status: status,
      );
      if (shown) return;
    }

    // Fallback to standard notification
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'connection_status',
          'Connection Status',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Show a command completion notification.
  /// Tries Super Island first on Xiaomi devices, falls back to standard.
  static Future<void> showCommandNotification({
    required String title,
    required String body,
    String? hostname,
  }) async {
    await init();
    final id = _notificationId++;

    // Try Super Island on Xiaomi HyperOS
    if (hostname != null) {
      final shown = await SuperIslandService.showCommandNotification(
        notificationId: id,
        title: title,
        body: body,
        hostname: hostname,
      );
      if (shown) return;
    }

    // Fallback to standard notification
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'command_alerts',
          'Command Alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  static Future<void> showCustomTriggerNotification({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_triggers',
          'Custom Triggers',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }
}
