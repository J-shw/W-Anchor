import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:w_anchor/models/anchoring_session.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
  });

  final AnchoringSession session;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = DateTime.fromMillisecondsSinceEpoch(session.startDatetime);
    final endTime = session.endDatetime != null
        ? DateTime.fromMillisecondsSinceEpoch(session.endDatetime!)
        : null;

    final duration = endTime != null
        ? endTime.difference(startTime)
        : DateTime.now().difference(startTime);

    final String durationDisplay = _formatDuration(duration);
    final String startTimeDisplay = DateFormat('h:mm a').format(startTime);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name ?? 'Anchorage',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 16,
                          color: theme.colorScheme.onSecondaryContainer.withValues(alpha:0.7)),
                      const SizedBox(width: 8),
                      Text(
                        'Started at $startTimeDisplay',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSecondaryContainer.withValues(alpha:0.7)),
                      const SizedBox(width: 8),
                      Text(
                        '${session.latitude.toStringAsFixed(4)}°, ${session.longitude.toStringAsFixed(4)}°',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Duration'),
                Text(
                  durationDisplay,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}