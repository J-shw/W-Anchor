import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:w_anchor/utils/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
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
      'Service Status',
      description: 'Low-priority ongoing monitoring status.',
      importance: Importance.low,
      playSound: false,
      showBadge: false
    );
    
    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      alarmChannelId,
      'Alarms',
      description: 'Critical alerts.',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('anchor_alarm'),
      playSound: true,
      enableVibration: true,
      enableLights: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      showBadge: true
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
  void showStatusNotification(String content) {
    _flutterLocalNotificationsPlugin.show(
      serviceNotificationId,
      "Background Status",
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          serviceChannelId,
          'Service Status',
          icon: '@mipmap/ic_launcher',
          ongoing: true,
          playSound: false,
        ),
      ),
    );
  }

  /// Show a high-priority alarm notification
  void showAlarmNotification(String content) {
    _flutterLocalNotificationsPlugin.show(
      alarmNotificationId,
      "Anchor Alarm",
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          alarmChannelId,
          'Alarms',
          icon: '@mipmap/ic_launcher',
          ongoing: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ),
    );
}
}