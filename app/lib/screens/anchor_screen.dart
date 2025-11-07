import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:w_anchor/database/repositories/anchor_repository.dart';
import 'package:w_anchor/models/anchoring_session.dart';
import 'package:w_anchor/widgets/info_box.dart';

class AnchorScreen extends StatefulWidget {
  const AnchorScreen({super.key});

  @override
  State<AnchorScreen> createState() => _AnchorScreenState();
}

class _AnchorScreenState extends State<AnchorScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  late AnchorRepository _repository;
  AnchoringSession? _activeSession; 
  bool _isLoading = true;

  double _currentAccuracy = 0.0;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  double _distanceFromAnchor = 0.0;

  StreamSubscription<Position>? _positionStreamSubscription;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _repository = AnchorRepository();
    _loadActiveSession();
    _startListeningToLocation(); 
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveSession() async {
    final session = await _repository.getActiveAnchoring();
    setState(() {
      _activeSession = session;
      _isLoading = false;
    });
  }

  Future<void> _startAnchoring() async {
    final newSession = AnchoringSession(
      startDatetime: DateTime.now().millisecondsSinceEpoch,
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      active: true,
    );
    final newId = await _repository.startNewAnchoring(newSession);

    setState(() {
      _activeSession = AnchoringSession(
        id: newId,
        startDatetime: newSession.startDatetime,
        latitude: newSession.latitude,
        longitude: newSession.longitude,
        active: true,
      );
      _distanceFromAnchor = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anchor position set!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _stopAnchoring() async {
    if (_activeSession == null) return;

    final int sessionId = _activeSession!.id!;
    final int endTime = DateTime.now().millisecondsSinceEpoch;

    await _repository.endAnchoring(sessionId, endTime);

    setState(() {
      _activeSession = null;
      _distanceFromAnchor = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anchoring session ended.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _startListeningToLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _currentAccuracy = -1; });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() { _currentAccuracy = -1; });
      return;
    } 

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings
    ).listen((Position? position) {
      if (position != null) {
        setState(() {
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
          
          if (position.accuracy < 50 && mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(_currentPosition),
            );
          }
        });
      }
    });
  }

  Set<Marker> _buildMarkers() {
    if (_activeSession == null) {
      return {};
    }
    return {
      Marker(
        markerId: const MarkerId('anchor'),
        position: LatLng(_activeSession!.latitude, _activeSession!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Anchor Position'),
      )
    };
  }

  Set<Circle> _buildCircles() {
    if (_activeSession == null) {
      return {};
    }
    return {
      Circle(
        circleId: const CircleId('anchor_circle'),
        center: LatLng(_activeSession!.latitude, _activeSession!.longitude),
        radius: 5,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withOpacity(0.3),
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('W Anchor'),
      ),
      
      floatingActionButton: _activeSession == null
          ? FloatingActionButton.extended(
              onPressed: _startAnchoring,
              label: const Text('Set Anchor'),
              icon: const Icon(Icons.anchor),
            )
          : FloatingActionButton.extended(
              onPressed: _stopAnchoring,
              label: const Text('Stop Anchoring'),
              icon: const Icon(Icons.not_interested),
              backgroundColor: Colors.red,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 15.0,
                        ),
                        myLocationEnabled: true, 
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        compassEnabled: true,
                        markers: _buildMarkers(),
                        circles: _buildCircles(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), 
                  InfoBox(
                    title: 'Distance from Anchor',
                    value: _activeSession == null
                        ? '---'
                        : '${_distanceFromAnchor.toStringAsFixed(1)} m',
                  ),
                  
                  const SizedBox(height: 10), 
                  
                  Row(
                    children: [
                      Expanded(
                        child: InfoBox(
                          title: 'GPS Accuracy',
                          value: '${_currentAccuracy.toStringAsFixed(1)} m',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InfoBox(
                          title: 'Current Coordinates',
                          value: '${_currentPosition.latitude.toStringAsFixed(4)}°\n${_currentPosition.longitude.toStringAsFixed(4)}°',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }
}