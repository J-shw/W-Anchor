import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/widgets/info_box.dart';
import 'package:w_anchor/utils/constants.dart';
import 'dart:async';

class AnchorScreen extends StatefulWidget {
  const AnchorScreen({super.key});

  @override
  State<AnchorScreen> createState() => _AnchorScreenState();
}

class _AnchorScreenState extends State<AnchorScreen> {
  Timer? _timer;
  String _timeSinceUpdate = '--';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    final provider = context.read<AnchorProvider>();

    if (provider.lastGpsRefresh == null) {
      setState(() {
        _timeSinceUpdate = '--';
      });
    } else {
      final diffInSeconds =
          DateTime.now().difference(provider.lastGpsRefresh!).inSeconds;
      setState(() {
        _timeSinceUpdate = '${diffInSeconds}s ago';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnchorProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String accuracyValue =
        '${provider.currentAccuracy.toStringAsFixed(1)} m\n$_timeSinceUpdate';

    final Color alarmColor;
    switch (provider.alarmStatus) {
      case AlarmStatus.outsideRadius:
        alarmColor = Colors.red;
        break;
      case AlarmStatus.noGps:
        alarmColor = Colors.orange;
        break;
      case AlarmStatus.none:
        alarmColor = Colors.transparent;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (provider.isAlarmActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: alarmColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                provider.alarmMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: [
              InfoBox(
                title: 'Distance from Anchor',
                value: provider.activeSession == null
                    ? '---'
                    : '${provider.distanceFromAnchor.toStringAsFixed(1)} m',
                isLarge: true,
              ),
              InfoBox(
                title: 'GPS Accuracy',
                value: accuracyValue,
              ),
              InfoBox(
                title: 'Anchor Coordinates',
                value: provider.activeSession == null
                    ? '--°\n--°'
                    : '${provider.activeSession!.latitude.toStringAsFixed(4)}°\n${provider.activeSession!.longitude.toStringAsFixed(4)}°',
              ),
              InfoBox(
                title: 'Current Coordinates',
                value: '${provider.currentPosition.latitude.toStringAsFixed(4)}°\n${provider.currentPosition.longitude.toStringAsFixed(4)}°',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: GoogleMap(
                onMapCreated: (controller) {
                  context.read<AnchorProvider>().setMapController(controller);
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(45.521563, -122.677433),
                  zoom: 11.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                compassEnabled: true,
                markers: provider.mapMarkers,
                circles: provider.mapCircles,
              ),
            ),
          ),
        ],
      ),
    );
  }
}