import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final bool isLarge;

  const InfoBox({
    super.key,
    required this.title,
    required this.value,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: isLarge
                ? TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  )
                : TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
            maxLines: isLarge ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}