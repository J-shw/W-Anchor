import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:w_anchor/utils/constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId == null) {
    debugPrint('Notification tap event was null. Cannot process command.');
    return;
  }

  debugPrint('notification tap background: ${notificationResponse.actionId}');
  if (notificationResponse.actionId == stopActionId) {
    FlutterBackgroundService().invoke(stopServiceCommand);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher_monochrome');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
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
      NotificationDetails(
        android: AndroidNotificationDetails(
          serviceChannelId,
          'Service Status',
          icon: '@drawable/ic_launcher_monochrome',
          ongoing: true,
          playSound: false,
          actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            stopActionId,
            'STOP',
            // cancelNotification: true,
            showsUserInterface: false,
          ),
        ],
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
          icon: '@drawable/ic_launcher_monochrome',
          ongoing: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ),
    );
  }

  Future<void> dismissAlarmNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(alarmNotificationId);
  }
}