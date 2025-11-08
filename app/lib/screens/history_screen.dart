import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/models/anchoring_session.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDateHeader(DateTime date) {
    final now = DateUtils.dateOnly(DateTime.now());
    final today = DateUtils.dateOnly(date);

    if (DateUtils.isSameDay(today, now)) {
      return 'Today';
    }
    
    final yesterday = now.subtract(const Duration(days: 1));
    if (DateUtils.isSameDay(today, yesterday)) {
      return 'Yesterday';
    }

    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnchorProvider>();
    final pastSessions = provider.pastSessions;

    if (pastSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off_outlined,
                size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No Anchor History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Your past anchoring sessions will appear here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      itemCount: pastSessions.length,
      itemBuilder: (context, index) {
        final session = pastSessions[index];
        final sessionDate =
            DateUtils.dateOnly(DateTime.fromMillisecondsSinceEpoch(session.startDatetime));
        final prevSession = (index > 0) ? pastSessions[index - 1] : null;
        final prevDate = prevSession != null
            ? DateUtils.dateOnly(DateTime.fromMillisecondsSinceEpoch(prevSession.startDatetime))
            : null;

        final bool showHeader = prevDate == null || !DateUtils.isSameDay(sessionDate, prevDate);

        if (showHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  _formatDateHeader(sessionDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _SessionCard(session: session),
            ],
          );
        } else {
          return _SessionCard(session: session);
        }
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
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
    final startTime = DateTime.fromMillisecondsSinceEpoch(session.startDatetime);
    final endTime = session.endDatetime != null
        ? DateTime.fromMillisecondsSinceEpoch(session.endDatetime!)
        : null;
    final duration = endTime != null
        ? endTime.difference(startTime)
        : DateTime.now().difference(startTime);

    final String startTimeDisplay = DateFormat('h:mm a').format(startTime);
    final String endTimeDisplay = endTime != null ? DateFormat('h:mm a').format(endTime) : 'Active';
    final String durationDisplay = _formatDuration(duration);

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: Icon(Icons.anchor, color: Theme.of(context).colorScheme.primary),
        title: Text(
          session.name ?? 'Anchorage',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Time: $startTimeDisplay - $endTimeDisplay\n'
          'Coords: ${session.latitude.toStringAsFixed(4)}°, ${session.longitude.toStringAsFixed(4)}°',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Duration', style: TextStyle(fontSize: 12)),
            Text(
              durationDisplay,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}