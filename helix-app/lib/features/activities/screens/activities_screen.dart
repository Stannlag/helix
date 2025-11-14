import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/activity_service.dart';
import '../models/activity_model.dart';
import '../widgets/activity_card.dart';
import 'activity_form_screen.dart';
import '../../../core/theme/app_colors.dart';

/// Activities Screen - Manage all activities
class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActivityCard(
                  activity: activity,
                  onTap: () => _editActivity(context, activity),
                  onDelete: () => _deleteActivity(context, ref, activity),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading activities: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(activitiesStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createActivity(context),
        icon: const Icon(Icons.add),
        label: const Text('New Activity'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Activities Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first activity to start\ntracking your time!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _createActivity(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Activity'),
            ),
          ],
        ),
      ),
    );
  }

  void _createActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivityFormScreen(),
      ),
    );
  }

  void _editActivity(BuildContext context, ActivityModel activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(activity: activity),
      ),
    );
  }

  Future<void> _deleteActivity(
    BuildContext context,
    WidgetRef ref,
    ActivityModel activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text(
          'Are you sure you want to delete "${activity.name}"?\n\nAll sessions for this activity will remain but won\'t be linked to it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final activityService = ref.read(activityServiceProvider);
        await activityService.deleteActivity(activity.userId, activity.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${activity.name} deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting activity: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
