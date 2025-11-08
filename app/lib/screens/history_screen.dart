import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:w_anchor/providers/anchor_provider.dart';
import 'package:w_anchor/widgets/history/session_card.dart';

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
              SessionCard(session: session),
            ],
          );
        } else {
          return SessionCard(session: session);
        }
      },
    );
  }
}