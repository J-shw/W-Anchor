import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/models/anchoring_session.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/widgets/info_box.dart';

class AnchorScreen extends StatelessWidget {
  const AnchorScreen({super.key});

  Set<Marker> _buildMarkers(AnchoringSession? activeSession) {
    if (activeSession == null) return {};
    return {
      Marker(
        markerId: const MarkerId('anchor'),
        position: LatLng(activeSession.latitude, activeSession.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      )
    };
  }

  Set<Circle> _buildCircles(AnchoringSession? activeSession) {
    if (activeSession == null) return {};
    return {
      Circle(
        circleId: const CircleId('anchor_circle'),
        center: LatLng(activeSession.latitude, activeSession.longitude),
        radius: 5,
        strokeColor: Colors.blue,
        strokeWidth: 2,
        fillColor: Colors.blue.withValues(alpha:0.3),
      )
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnchorProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
                markers: _buildMarkers(provider.activeSession),
                circles: _buildCircles(provider.activeSession),
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
              ),
              InfoBox(
                title: 'GPS Accuracy',
                value: '${provider.currentAccuracy.toStringAsFixed(1)} m',
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
        ],
      ),
    );
  }
}