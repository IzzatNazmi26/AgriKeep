import 'package:flutter/material.dart';
import 'package:agrikeep/utils/theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final bool interactive;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius resolvedRadius =
    borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : BorderRadius.circular(12);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: backgroundColor ?? AgriKeepTheme.surfaceColor,
        borderRadius: resolvedRadius, // ✅ FIXED
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedRadius, // ✅ FIXED
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? resolvedRadius,
              border: border ??
                  Border.all(
                    color: AgriKeepTheme.borderColor,
                    width: 1,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}


// Specialized Cards

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final Color? color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trend,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AgriKeepTheme.primaryColor;
    final backgroundColor = iconColor.withOpacity(0.1);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AgriKeepTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AgriKeepTheme.successColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AgriKeepTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AgriKeepTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

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

    return CustomCard(
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