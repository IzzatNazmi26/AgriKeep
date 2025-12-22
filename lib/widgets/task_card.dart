import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';
import 'package:agrikeep/widgets/card.dart' as custom_card;

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String dueDate;
  final TaskPriority priority;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityStyle = _getPriorityStyle(priority);

    return custom_card.CustomCard(
      onTap: onTap,
      border: Border(
        left: BorderSide(
          color: priorityStyle.color,
          width: 4,
        ),
        top: BorderSide(color: AgriKeepTheme.borderColor),
        right: BorderSide(color: AgriKeepTheme.borderColor),
        bottom: BorderSide(color: AgriKeepTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: priorityStyle.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              priority == TaskPriority.high
                  ? Icons.warning_amber
                  : Icons.notifications,
              size: 20,
              color: priorityStyle.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AgriKeepTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AgriKeepTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Due: $dueDate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgriKeepTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _PriorityStyle _getPriorityStyle(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return _PriorityStyle(
          color: AgriKeepTheme.errorColor,
          backgroundColor: AgriKeepTheme.errorColor.withOpacity(0.1),
        );
      case TaskPriority.medium:
        return _PriorityStyle(
          color: AgriKeepTheme.warningColor,
          backgroundColor: AgriKeepTheme.warningColor.withOpacity(0.1),
        );
      case TaskPriority.low:
        return _PriorityStyle(
          color: AgriKeepTheme.infoColor,
          backgroundColor: AgriKeepTheme.infoColor.withOpacity(0.1),
        );
    }
  }
}

class _PriorityStyle {
  final Color color;
  final Color backgroundColor;

  _PriorityStyle({
    required this.color,
    required this.backgroundColor,
  });
}

enum TaskPriority { high, medium, low }