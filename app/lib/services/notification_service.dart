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
    const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
      serviceChannelId,
      'W Anchor Service Status',
      description: 'Low-priority ongoing monitoring status.',
      importance: Importance.low,
      playSound: false,
    );
    
    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      alarmChannelId,
      'W Anchor Alarm',
      description: 'Critical alerts when the anchor is dragged.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(serviceChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alarmChannel);
  }

  /// Show a low-priority status notification
  void showStatusNotification(String title, String content) {
    _flutterLocalNotificationsPlugin.show(
      serviceNotificationId,
      title,
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          serviceChannelId,
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

  /// Show a high-priority alarm notification
  void showAlarmNotification(String title, String content) {
    _flutterLocalNotificationsPlugin.show(
      alarmNotificationId,
      title,
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          alarmChannelId,
          'W Anchor Service',
          icon: '@mipmap/ic_launcher',
          ongoing: true,
          playSound: true,
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
}
}