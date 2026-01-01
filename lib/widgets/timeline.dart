import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/models/activity.dart'; // ← ADD THIS IMPORT

class TimelineItem {
  final String date;
  final String title;
  final String description;
  final bool completed;

  TimelineItem({
    required this.date,
    required this.title,
    required this.description,
    required this.completed,
  });

  // Add this factory method
  factory TimelineItem.fromActivity(Activity activity) {
    String description = activity.generalNotes ?? 'No additional notes';
    if (activity.fertilizerType != null && activity.fertilizerType != 'None') {
      description += '\nFertilizer: ${activity.fertilizerType}';
      if (activity.fertilizerAmount != null) {
        description += ' (${activity.fertilizerAmount}kg)';
      }
    }

    return TimelineItem(
      date: '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}-${activity.date.day.toString().padLeft(2, '0')}',
      title: activity.activityType,
      description: description,
      completed: true,
    );
  }
}


class Timeline extends StatelessWidget {
  final List<TimelineItem> items;

  const Timeline({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return _buildTimelineItem(item, index == items.length - 1);
      }).toList(),
    );
  }

  Widget _buildTimelineItem(TimelineItem item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and icon
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.completed
                    ? AgriKeepTheme.primaryColor
                    : AgriKeepTheme.borderColor,
              ),
              child: Icon(
                item.completed ? Icons.check : Icons.circle,
                size: 16,
                color: item.completed ? Colors.white : AgriKeepTheme.textTertiary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AgriKeepTheme.borderColor,
                margin: const EdgeInsets.only(top: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: item.completed
                            ? AgriKeepTheme.textPrimary
                            : AgriKeepTheme.textTertiary,
                      ),
                    ),
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AgriKeepTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.completed
                        ? AgriKeepTheme.textSecondary
                        : AgriKeepTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}