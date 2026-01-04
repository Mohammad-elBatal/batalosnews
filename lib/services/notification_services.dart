import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  static final NotificationServices _instance = NotificationServices._internal();
  factory NotificationServices() {
    return _instance;
  }
  NotificationServices._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize({bool isBackground = false}) async {
  if (_isInitialized && !isBackground) return;
  if (!isBackground) {
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettingsIOS = DarwinInitializationSettings();
  
  const initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );
  await notificationsPlugin.initialize(initSettings);
  _isInitialized = true;
}

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_updates_channel',
        'Daily Updates',
        channelDescription: 'Notifications for new articles',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
    );
  }
}