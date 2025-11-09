import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:w_anchor/models/anchoring_session.dart';
import 'package:w_anchor/utils/constants.dart';
import 'package:w_anchor/services/notification_service.dart';

final NotificationService notificationService = NotificationService();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  StreamSubscription<Position>? positionStream;
  Timer? gpsWatchdogTimer;
  AnchoringSession? activeSession;
  double currentAlarmRadius = defaultAlarmRadius;
  DateTime? lastGpsRefresh;
  AlarmStatus alarmStatus = AlarmStatus.none;
  bool alarmTriggered = false;

  notificationService.showStatusNotification(
    "W Anchor",
    "Monitoring your anchor position.",
  );

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    notificationService.showStatusNotification(
      "W Anchor",
      "Service is running, but location is denied.",
    );
  } else {
    positionStream =
        Geolocator.getPositionStream(
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


            service.invoke('updateUI', {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'accuracy': position.accuracy.toDouble(),
              'distance': distance.toDouble(),
              'alarmStatus': alarmStatus.index,
              'lastGpsRefresh': lastGpsRefresh!.millisecondsSinceEpoch,
            });

            if (alarmStatus == AlarmStatus.none) {
              notificationService.showStatusNotification("W Anchor", "All clear. Monitoring.");
              alarmTriggered = false;
            }
            else if (alarmStatus == AlarmStatus.noGps) {
              notificationService.showStatusNotification("W Anchor", "WARNING: No GPS signal...");
            }
            else if (alarmStatus == AlarmStatus.outsideRadius) {
              if (!alarmTriggered) {
                alarmTriggered = true;
                 notificationService.showStatusNotification("W Anchor", "ALARM: Outside radius!");
                notificationService.showAlarmNotification("W Anchor", "ALARM: Outside radius!");
              }
            }
          }
        });
  }

  gpsWatchdogTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    if (lastGpsRefresh == null) return;
    final int secondsSinceUpdate = DateTime.now()
        .difference(lastGpsRefresh!)
        .inSeconds;

    if (secondsSinceUpdate > 15 && alarmStatus != AlarmStatus.outsideRadius) {
      alarmStatus = AlarmStatus.noGps;
      service.invoke('updateUI', {'alarmStatus': alarmStatus.index});
      notificationService.showStatusNotification("W Anchor", "WARNING: No GPS signal...");
    }
  });

  service.on('setAnchor').listen((map) {
    activeSession = AnchoringSession.fromMap(map!['session']);
    lastGpsRefresh = DateTime.now();
    alarmStatus = AlarmStatus.none;
    service.invoke('updateUI', {
      'distance': 0.0,
      'alarmStatus': alarmStatus.index,
    });
    notificationService.showStatusNotification("W Anchor", "Anchor set. All clear.");
  });

  service.on('stopAnchor').listen((map) {
    activeSession = null;
    if (alarmStatus != AlarmStatus.noGps) {
      alarmStatus = AlarmStatus.none;
    }
    service.invoke('updateUI', {
      'distance': 0.0,
      'alarmStatus': alarmStatus.index,
    });
    notificationService.showStatusNotification("W Anchor", "Anchor monitoring stopped.");
  });

  service.on('updateSettings').listen((map) {
    if (map != null && map.containsKey('alarmRadius')) {
      currentAlarmRadius = (map['alarmRadius'] as num).toDouble();
    }
  });

  service.on('stop').listen((map) {
    positionStream?.cancel();
    gpsWatchdogTimer?.cancel();
    service.stopSelf();
  });
}
