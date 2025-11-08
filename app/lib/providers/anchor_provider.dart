import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:w_anchor/models/anchoring_session.dart';
import 'package:w_anchor/database/repositories/anchor_repository.dart';
import 'package:w_anchor/providers/settings_provider.dart';
import 'package:w_anchor/utils/constants.dart';

class AnchorProvider with ChangeNotifier {
  final AnchorRepository _repository = AnchorRepository();
  final _service = FlutterBackgroundService();

  AnchoringSession? _activeSession;
  GoogleMapController? _mapController;
  SettingsProvider? _settings;
  DateTime? _lastGpsRefresh;
  AlarmStatus _alarmStatus = AlarmStatus.none;

  double _currentAccuracy = 0.0;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  double _distanceFromAnchor = 0.0;
  bool _isLoading = true;
  List<AnchoringSession> _pastSessions = [];

  AnchoringSession? get activeSession => _activeSession;
  double get currentAccuracy => _currentAccuracy;
  LatLng get currentPosition => _currentPosition;
  double get distanceFromAnchor => _distanceFromAnchor;
  bool get isLoading => _isLoading;
  List<AnchoringSession> get pastSessions => _pastSessions;
  DateTime? get lastGpsRefresh => _lastGpsRefresh;
  bool get isAlarmActive => _alarmStatus != AlarmStatus.none;
  AlarmStatus get alarmStatus => _alarmStatus;

  String get alarmMessage {
    switch (_alarmStatus) {
      case AlarmStatus.none:
        return 'All clear';
      case AlarmStatus.outsideRadius:
        return 'ALARM: Outside radius! (${_distanceFromAnchor.toStringAsFixed(0)}m)';
      case AlarmStatus.noGps:
        return 'WARNING: No GPS signal...';
    }
  }

  double get alarmRadius {
    return _settings?.alarmRadius ?? defaultAlarmRadius;
  }

  AnchorProvider() {
    _loadActiveSession();

    _service.on('updateUI').listen((data) {
      if (data == null) return;
      
      if (data.containsKey('latitude')) {
        _currentPosition = LatLng(
          (data['latitude'] as num).toDouble(),
          (data['longitude'] as num).toDouble()
        );
        _currentAccuracy = (data['accuracy'] as num).toDouble();
      }
      if (data.containsKey('distance')) {
        _distanceFromAnchor = (data['distance'] as num).toDouble();
      }
      if (data.containsKey('alarmStatus')) {
        _alarmStatus = AlarmStatus.values[data['alarmStatus']];
      }
      if (data.containsKey('lastGpsRefresh')) {
        _lastGpsRefresh =
            DateTime.fromMillisecondsSinceEpoch(data['lastGpsRefresh']);
      }
      notifyListeners();
    });
  } 

  Set<Marker> get mapMarkers {
    if (_activeSession == null) return {};
    return {
      Marker(
        markerId: const MarkerId('anchor'),
        position: LatLng(_activeSession!.latitude, _activeSession!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      )
    };
  }

  Set<Circle> get mapCircles {
    if (_activeSession == null) return {};
    return {
      Circle(
        circleId: const CircleId('anchor_circle'),
        center: LatLng(_activeSession!.latitude, _activeSession!.longitude),
        radius: alarmRadius,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withValues(alpha: 0.3),
      )
    };
  }

  /// This is called from main.dart
  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    _service.invoke('updateSettings', {'alarmRadius': alarmRadius});
    notifyListeners();
  }

  /// Load the session from the DB when app starts
  Future<void> _loadActiveSession() async {
    _activeSession = await _repository.getActiveAnchoring();
    _isLoading = false;
    if (_activeSession != null) {
      _service.invoke('setAnchor', {'session': _activeSession!.toMap()});
    }
    
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Start a new anchoring session
  Future<void> startAnchoring() async {
    final newSession = AnchoringSession(
      startDatetime: DateTime.now().millisecondsSinceEpoch,
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      active: true,
    );

    final newId = await _repository.startNewAnchoring(newSession);
    _activeSession = AnchoringSession.fromMap(newSession.toMap()..['id'] = newId);
    _service.invoke('setAnchor', {'session': _activeSession!.toMap()});

    _distanceFromAnchor = 0.0;
    notifyListeners();
  }

  /// Stop the current anchoring session
  Future<void> stopAnchoring() async {
    if (_activeSession == null) return;

    await _repository.endAnchoring(
      _activeSession!.id!,
      DateTime.now().millisecondsSinceEpoch,
    );
    _activeSession = null;

    _service.invoke('stopAnchor');

    _distanceFromAnchor = 0.0;
    if (_alarmStatus != AlarmStatus.noGps) {
      _alarmStatus = AlarmStatus.none;
    }
    notifyListeners();
  }

  /// Loads the history page
  Future<void> loadHistory() async {
    _pastSessions = await _repository.getAllAnchorings();
    notifyListeners();
  }

  /// Deletes a session and refreshes the history list
  Future<void> deleteAnchoring(int id) async {
    await _repository.deleteAnchoring(id);
    await loadHistory();
  }
}