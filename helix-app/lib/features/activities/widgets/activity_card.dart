import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../screens/activity_stats_screen.dart';
import '../../sessions/services/session_service.dart';
import '../../../core/theme/app_colors.dart';

/// Activity Card Widget - Displays an activity with color, name, and goal
class ActivityCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Get sessions to calculate weekly progress if goal is set
    final sessionsAsync = activity.weeklyGoalMinutes != null
        ? ref.watch(sessionsStreamProvider)
        : null;

    // Calculate current week's progress
    int currentWeekMinutes = 0;
    double progressPercentage = 0.0;

    if (activity.weeklyGoalMinutes != null && sessionsAsync != null) {
      sessionsAsync.whenData((sessions) {
        // Get start of current week (Monday)
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

        // Sum up sessions for this activity in current week
        currentWeekMinutes = sessions
            .where((session) =>
                session.activityId == activity.id &&
                session.startTime.isAfter(weekStartDate))
            .fold(0, (sum, session) => sum + session.durationMinutes);

        progressPercentage = (currentWeekMinutes / activity.weeklyGoalMinutes!) * 100;
      });
    }

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
                    // Weekly Goal Progress
                    if (activity.weeklyGoalMinutes != null) ...[
                      const SizedBox(height: 8),
                      _buildProgressBar(
                        context,
                        currentWeekMinutes,
                        activity.weeklyGoalMinutes!,
                        progressPercentage,
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stats button
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    color: AppColors.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityStatsScreen(activity: activity),
                        ),
                      );
                    },
                    tooltip: 'View statistics',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    int currentMinutes,
    int goalMinutes,
    double percentage,
  ) {
    // Determine progress bar color based on percentage
    Color progressColor;
    if (percentage >= 80) {
      progressColor = AppColors.success;
    } else if (percentage >= 50) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppColors.error;
    }

    // Format time display
    final currentHours = currentMinutes ~/ 60;
    final currentMins = currentMinutes % 60;
    final goalHours = goalMinutes ~/ 60;
    final goalMins = goalMinutes % 60;

    String currentTimeStr = currentHours > 0
        ? '${currentHours}h ${currentMins}m'
        : '${currentMins}m';
    String goalTimeStr = goalHours > 0
        ? '${goalHours}h ${goalMins}m'
        : '${goalMins}m';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Goal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
            ),
            Text(
              '$currentTimeStr / $goalTimeStr',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.textDisabled.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
