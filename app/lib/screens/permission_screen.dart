import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:w_anchor/screens/main_screen.dart';

/// Checks critical permissions: location and background location.
/// Returns true if all required location permissions are granted.
Future<bool> requestCriticalLocationPermissions() async {
  PermissionStatus locationStatus = await Permission.location.request();
  
  if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
    return false;
  }

  PermissionStatus backgroundStatus = await Permission.locationAlways.status;

  if (backgroundStatus != PermissionStatus.granted) {
    backgroundStatus = await Permission.locationAlways.request();
  }
  
  return backgroundStatus.isGranted;
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  void _checkAndRequestPermissions() async {
    await Permission.notification.request();
    bool granted = await requestCriticalLocationPermissions();

    if (granted) {
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();
      if (!isRunning) {
        await service.startService();
      }
    }
    
    if (mounted) {
      setState(() {
        _permissionsGranted = granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionsGranted) {
      return const MainScreen(); 
    } else {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person, size: 50, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Required permissions not granted.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please grant location and notification access to start monitoring.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}