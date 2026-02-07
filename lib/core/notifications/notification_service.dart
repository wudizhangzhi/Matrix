import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  static Future<void> showConnectionNotification({
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
          'connection_status',
          'Connection Status',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> showCommandNotification({
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
