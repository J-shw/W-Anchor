import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:w_anchor/models/anchoring_session.dart';
import 'package:w_anchor/utils/constants.dart'; 

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'W Anchor Service',
    description: 'W Anchor is monitoring your position.',
    importance: Importance.low,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  StreamSubscription<Position>? positionStream;
  Timer? gpsWatchdogTimer;
  AnchoringSession? activeSession;
  double currentAlarmRadius = defaultAlarmRadius;
  DateTime? lastGpsRefresh;
  AlarmStatus alarmStatus = AlarmStatus.none;

  void updateNotification(String content) {
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'W Anchor',
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

  updateNotification("Monitoring your anchor position.");

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || 
      permission == LocationPermission.deniedForever) {
    updateNotification("Service is running, but location is denied.");
  } else {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position? position) {
      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((Position? position) {
        if (position != null) {
          lastGpsRefresh = DateTime.now();
          double distance = 0.0;
          bool isOutside = false;

          if (activeSession != null) {
            distance = Geolocator.distanceBetween(
              activeSession!.latitude,
              activeSession!.longitude,
              position.latitude,
              position.longitude,
            );
            isOutside = distance > currentAlarmRadius;
          }

          if (activeSession != null) {
            if (isOutside) {
              alarmStatus = AlarmStatus.outsideRadius;
            } else {
              alarmStatus = AlarmStatus.none;
            }
          } else {
            alarmStatus = AlarmStatus.none;
          }

          service.invoke(
            'updateUI',
            {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'accuracy': position.accuracy,
              'distance': distance,
              'alarmStatus': alarmStatus.index,
              'lastGpsRefresh': lastGpsRefresh!.millisecondsSinceEpoch,
            },
          );

          String content = "All clear. Monitoring.";
          if (alarmStatus == AlarmStatus.outsideRadius) {
            content = "ALARM: Outside radius! (${distance.toStringAsFixed(0)}m)";
          } else if (alarmStatus == AlarmStatus.noGps) {
            content = "WARNING: No GPS signal...";
          }

          updateNotification(content);
        }
      });
    });
  }

  gpsWatchdogTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    if (lastGpsRefresh == null) return;
    final int secondsSinceUpdate =
        DateTime.now().difference(lastGpsRefresh!).inSeconds;

    if (secondsSinceUpdate > 15 && alarmStatus != AlarmStatus.outsideRadius) {
      alarmStatus = AlarmStatus.noGps;
      service.invoke(
        'updateUI',
        {'alarmStatus': alarmStatus.index},
      );
      updateNotification("WARNING: No GPS signal...");
    }
  });

  service.on('setAnchor').listen((map) {
    activeSession = AnchoringSession.fromMap(map!['session']);
    lastGpsRefresh = DateTime.now();
    alarmStatus = AlarmStatus.none;
    service.invoke('updateUI', {'distance': 0.0, 'alarmStatus': alarmStatus.index});
    updateNotification("Anchor set. All clear.");
  });

  service.on('stopAnchor').listen((map) {
    activeSession = null;
    if (alarmStatus != AlarmStatus.noGps){
      alarmStatus = AlarmStatus.none;
    }
    service.invoke('updateUI', {'distance': 0.0, 'alarmStatus': alarmStatus.index});
    updateNotification("Anchor monitoring stopped.");
  });

  service.on('updateSettings').listen((map) {
    if (map != null && map.containsKey('alarmRadius')) {
      currentAlarmRadius = map['alarmRadius'];
    }
  });

  service.on('stop').listen((map) {
    positionStream?.cancel();
    gpsWatchdogTimer?.cancel();
    service.stopSelf();
  });
}