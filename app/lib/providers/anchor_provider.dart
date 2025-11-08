import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:w_anchor/models/anchoring_session.dart';
import 'package:w_anchor/database/repositories/anchor_repository.dart';
import 'package:w_anchor/providers/settings_provider.dart';
import 'package:w_anchor/utils/constants.dart';

class AnchorProvider with ChangeNotifier {
  final AnchorRepository _repository = AnchorRepository();

  AnchoringSession? _activeSession;
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  SettingsProvider? _settings;

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

  AnchorProvider() {
    _loadActiveSession();
  }

  double get alarmRadius {
    return _settings?.alarmRadius ?? defaultAlarmRadius;
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
        fillColor: Colors.blue.withValues(alpha:0.3), 
      )
    };
  }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  Future<void> _loadActiveSession() async {
    _activeSession = await _repository.getActiveAnchoring();
    _isLoading = false;
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> startGpsStream() async {
    if (_positionStreamSubscription != null) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) {
      if (position != null) {
        _currentAccuracy = position.accuracy;
        _currentPosition = LatLng(position.latitude, position.longitude);

        if (_activeSession != null) {
          _distanceFromAnchor = Geolocator.distanceBetween(
            _activeSession!.latitude,
            _activeSession!.longitude,
            _currentPosition.latitude,
            _currentPosition.longitude,
          );
        }

        if (position.accuracy < 50 && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentPosition),
          );
        }

        notifyListeners();
      }
    });
  }

  void stopGpsStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> startAnchoring() async {
    final newSession = AnchoringSession(
      startDatetime: DateTime.now().millisecondsSinceEpoch,
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      active: true,
    );

    final newId = await _repository.startNewAnchoring(newSession);

    _activeSession = AnchoringSession(
      id: newId,
      startDatetime: newSession.startDatetime,
      latitude: newSession.latitude,
      longitude: newSession.longitude,
      active: true,
    );
    _distanceFromAnchor = 0.0;
    notifyListeners();
  }

  Future<void> stopAnchoring() async {
    if (_activeSession == null) return;

    await _repository.endAnchoring(
      _activeSession!.id!,
      DateTime.now().millisecondsSinceEpoch,
    );

    _activeSession = null;
    _distanceFromAnchor = 0.0;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _pastSessions = await _repository.getAllAnchorings();
    notifyListeners();
  }
}