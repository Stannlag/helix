import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../../../core/theme/app_colors.dart';

/// Activity Card Widget - Displays an activity with color, name, and goal
class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: activity.color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),

              // Activity info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (activity.goal != null && activity.goal!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.flag,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.goal!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.textSecondary,
                onPressed: onDelete,
                tooltip: 'Delete activity',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
