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

    final String startTimeDisplay = DateFormat('h:mm a').format(startTime);
    final String endTimeDisplay =
        endTime != null ? DateFormat('h:mm a').format(endTime) : 'Active';
    final String durationDisplay = _formatDuration(duration);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.name ?? 'Anchorage',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _InsightRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: durationDisplay,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),

            _InsightRow(
              icon: Icons.access_time_outlined,
              label: 'Time',
              value: '$startTimeDisplay - $endTimeDisplay',
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 8),

            _InsightRow(
              icon: Icons.location_on_outlined,
              label: 'Coords',
              value:
                  '${session.latitude.toStringAsFixed(4)}°, ${session.longitude.toStringAsFixed(4)}°',
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(color: color.withValues(alpha: 0.7)),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}