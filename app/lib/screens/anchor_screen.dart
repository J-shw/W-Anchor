import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class AnchorScreen extends StatefulWidget {
  const AnchorScreen({super.key});

  @override
  State<AnchorScreen> createState() => _AnchorScreenState();
}

class _AnchorScreenState extends State<AnchorScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);

  double _currentAccuracy = 0.0;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  
  LatLng? _anchorPosition;
  double _distanceFromAnchor = 0.0;
  
  StreamSubscription<Position>? _positionStreamSubscription;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _startListeningToLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _setAnchor() {
    setState(() {
      _anchorPosition = _currentPosition;
      _distanceFromAnchor = 0.0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anchor position set!'),
        backgroundColor: Colors.green,
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

          if (_anchorPosition != null) {
            _distanceFromAnchor = Geolocator.distanceBetween(
              _anchorPosition!.latitude,
              _anchorPosition!.longitude,
              _currentPosition.latitude,
              _currentPosition.longitude,
            );
          }
          
          if (position.accuracy < 50) {
            mapController.animateCamera(
              CameraUpdate.newLatLng(_currentPosition),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('W Anchor'),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _setAnchor,
        label: const Text('Set Anchor'),
        icon: const Icon(Icons.anchor),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Padding(
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
                    zoom: 11.0,
                  ),
                  myLocationEnabled: true, 
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
            const SizedBox(height: 16), 
            
            InfoBox(
              title: 'Distance from Anchor',
              value: '${_distanceFromAnchor.toStringAsFixed(1)} m',
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

// Reusable InfoBox widget (no changes)
class InfoBox extends StatelessWidget {
  final String title;
  final String value;
  
  const InfoBox({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200, 
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54, 
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}