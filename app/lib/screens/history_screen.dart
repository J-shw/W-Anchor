import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnchorProvider>();

    if (provider.pastSessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Anchoring History',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.pastSessions.length,
      itemBuilder: (context, index) {
        final session = provider.pastSessions[index];
        final startTime =
            DateTime.fromMillisecondsSinceEpoch(session.startDatetime);
        final endTime = session.endDatetime != null
            ? DateTime.fromMillisecondsSinceEpoch(session.endDatetime!)
            : null;
        final String dateDisplay =
            DateFormat('EEE, MMM d, yyyy').format(startTime);
        final String startTimeDisplay = DateFormat('h:mm a').format(startTime);
        final String endTimeDisplay =
            endTime != null ? DateFormat('h:mm a').format(endTime) : 'Active';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.anchor, color: Colors.blue),
            title: Text(session.name ?? 'Anchorage at $dateDisplay'),
            subtitle: Text(
              'Time: $startTimeDisplay - $endTimeDisplay\n'
              'Coords: ${session.latitude.toStringAsFixed(4)}°, ${session.longitude.toStringAsFixed(4)}°',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}