import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../../../core/theme/app_colors.dart';

/// Session Card Widget - Displays a session with activity, duration, and emoji
class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SessionCard({
    super.key,
    required this.session,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Activity color indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: session.activityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Activity name and duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.activityName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.formattedDuration,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Emoji rating
                  Text(
                    session.emojiRating,
                    style: const TextStyle(fontSize: 32),
                  ),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.textSecondary,
                    onPressed: onDelete,
                    tooltip: 'Delete session',
                  ),
                ],
              ),

              // Notes (if present)
              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
