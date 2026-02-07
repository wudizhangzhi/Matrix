import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BackgroundServiceManager {
  static final _service = FlutterBackgroundService();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const channel = AndroidNotificationChannel(
      'matrix_terminal_fg',
      'Matrix Terminal',
      description: 'Keeps SSH connections alive',
      importance: Importance.low,
    );

    final flnp = FlutterLocalNotificationsPlugin();
    await flnp
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'matrix_terminal_fg',
        initialNotificationTitle: 'Matrix Terminal',
        initialNotificationContent: 'SSH connections active',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
    );

    _initialized = true;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((_) {
        service.setAsBackgroundService();
      });
    }
    service.on('stopService').listen((_) {
      service.stopSelf();
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }

  static Future<void> startService(int sessionCount) async {
    await init();
    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
      await WakelockPlus.enable();
    }
  }

  static Future<void> stopService() async {
    _service.invoke('stopService');
    await WakelockPlus.disable();
  }
}
