import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:w_anchor/utils/constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'W Anchor Service',
      description: 'W Anchor is monitoring your position.',
      importance: Importance.low,
      playSound: false,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showNotification(String title, String content) {
    _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'W Anchor Service',
          icon: '@mipmap/ic_launcher',
          ongoing: true,
          playSound: false,
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
    );
  }
}