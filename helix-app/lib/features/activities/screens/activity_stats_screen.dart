import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity_model.dart';
import '../../sessions/services/session_service.dart';
import '../../sessions/models/session_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/emoji_ratings.dart';

/// Activity Stats Screen - Detailed statistics for a specific activity
class ActivityStatsScreen extends ConsumerWidget {
  final ActivityModel activity;

  const ActivityStatsScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
      ),
      body: sessionsAsync.when(
        data: (allSessions) {
          // Filter sessions for this activity
          final activitySessions = allSessions
              .where((session) => session.activityId == activity.id)
              .toList();

          if (activitySessions.isEmpty) {
            return _buildEmptyState(context);
          }

          final stats = _calculateStats(activitySessions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Activity color header
              _buildHeader(context),
              const SizedBox(height: 24),

              // Total time card
              _buildTotalTimeCard(context, stats['totalMinutes'] as int),
              const SizedBox(height: 16),

              // Average rating and session count
              Row(
                children: [
                  Expanded(
                    child: _buildAverageRatingCard(
                      context,
                      stats['averageRating'] as double,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSessionCountCard(
                      context,
                      activitySessions.length,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly goal progress (if set)
              if (activity.weeklyGoalMinutes != null) ...[
                _buildWeeklyGoalCard(
                  context,
                  stats['currentWeekMinutes'] as int,
                  activity.weeklyGoalMinutes!,
                ),
                const SizedBox(height: 24),
              ],

              // Time trend chart
              _buildTimeTrendCard(
                context,
                stats['weeklyTrend'] as List<Map<String, dynamic>>,
              ),
              const SizedBox(height: 24),

              // Emoji distribution
              _buildEmojiDistribution(
                context,
                stats['emojiDistribution'] as Map<String, int>,
              ),
              const SizedBox(height: 24),

              // Recent sessions
              _buildRecentSessions(
                context,
                activitySessions.take(5).toList(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error loading stats: $error'),
            ],
          ),
        ),
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
                color: activity.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart,
                size: 64,
                color: activity.color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Sessions Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging sessions for this\nactivity to see statistics!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: activity.color,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (activity.goal != null && activity.goal!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  activity.goal!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalTimeCard(BuildContext context, int totalMinutes) {
    final hours = totalMinutes / 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Total Time Spent',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hours >= 1
                  ? '${hours.toStringAsFixed(1)} hours'
                  : '$totalMinutes minutes',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: activity.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageRatingCard(BuildContext context, double avgRating) {
    String emoji = EmojiRatings.neutral;
    if (avgRating >= 3.5) {
      emoji = EmojiRatings.amazing;
    } else if (avgRating >= 2.5) {
      emoji = EmojiRatings.happy;
    } else if (avgRating >= 1.5) {
      emoji = EmojiRatings.neutral;
    } else {
      emoji = EmojiRatings.sad;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Avg Rating',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 4),
            Text(
              avgRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCountCard(BuildContext context, int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Sessions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            const Icon(
              Icons.event_note,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalCard(BuildContext context, int currentMinutes, int goalMinutes) {
    final percentage = (currentMinutes / goalMinutes * 100).clamp(0, 100);
    Color progressColor;
    if (percentage >= 80) {
      progressColor = AppColors.success;
    } else if (percentage >= 50) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppColors.error;
    }

    final currentHours = currentMinutes ~/ 60;
    final currentMins = currentMinutes % 60;
    final goalHours = goalMinutes ~/ 60;
    final goalMins = goalMinutes % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week\'s Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal: ${goalHours}h ${goalMins}m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  '${currentHours}h ${currentMins}m',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.textDisabled.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(0)}% complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTrendCard(BuildContext context, List<Map<String, dynamic>> weeklyTrend) {
    if (weeklyTrend.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Time Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklyTrend
                      .map((w) => (w['minutes'] as int).toDouble())
                      .reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= weeklyTrend.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            weeklyTrend[value.toInt()]['label'] as String,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyTrend.asMap().entries.map((entry) {
                    final index = entry.key;
                    final minutes = entry.value['minutes'] as int;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (minutes / 60).toDouble(),
                          color: activity.color,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiDistribution(BuildContext context, Map<String, int> distribution) {
    if (distribution.isEmpty) return const SizedBox.shrink();

    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmojiStat(
                    context, EmojiRatings.sad, distribution[EmojiRatings.sad] ?? 0, total),
                _buildEmojiStat(context, EmojiRatings.neutral,
                    distribution[EmojiRatings.neutral] ?? 0, total),
                _buildEmojiStat(
                    context, EmojiRatings.happy, distribution[EmojiRatings.happy] ?? 0, total),
                _buildEmojiStat(context, EmojiRatings.amazing,
                    distribution[EmojiRatings.amazing] ?? 0, total),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiStat(BuildContext context, String emoji, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildRecentSessions(BuildContext context, List<SessionModel> sessions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Recent Sessions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...sessions.map((session) {
              final hours = session.durationMinutes ~/ 60;
              final minutes = session.durationMinutes % 60;
              final durationStr = hours > 0
                  ? '${hours}h ${minutes}m'
                  : '${minutes}m';

              return ListTile(
                leading: Text(
                  session.emojiRating,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  '${session.date.month}/${session.date.day}/${session.date.year}',
                ),
                subtitle: Text(
                  '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')} - ${session.endTime.hour.toString().padLeft(2, '0')}:${session.endTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Text(
                  durationStr,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<SessionModel> sessions) {
    // Total minutes
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    // Average rating (convert emoji to numeric)
    final ratingMap = {
      EmojiRatings.sad: 1,
      EmojiRatings.neutral: 2,
      EmojiRatings.happy: 3,
      EmojiRatings.amazing: 4,
    };

    final totalRating = sessions.fold<int>(
      0,
      (sum, session) => sum + (ratingMap[session.emojiRating] ?? 2),
    );
    final averageRating = sessions.isNotEmpty ? totalRating / sessions.length : 0.0;

    // Current week minutes
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final currentWeekMinutes = sessions
        .where((session) => session.startTime.isAfter(weekStartDate))
        .fold<int>(0, (sum, session) => sum + session.durationMinutes);

    // Emoji distribution
    final emojiDistribution = <String, int>{};
    for (final session in sessions) {
      emojiDistribution[session.emojiRating] =
          (emojiDistribution[session.emojiRating] ?? 0) + 1;
    }

    // Weekly trend (last 4 weeks)
    final weeklyTrend = <Map<String, dynamic>>[];
    for (int i = 3; i >= 0; i--) {
      final weekEnd = DateTime.now().subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final weekStartNorm = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEndNorm = DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);

      final weekMinutes = sessions
          .where((session) =>
              session.startTime.isAfter(weekStartNorm) &&
              session.startTime.isBefore(weekEndNorm))
          .fold<int>(0, (sum, session) => sum + session.durationMinutes);

      weeklyTrend.add({
        'label': 'W${i == 0 ? '' : '-$i'}',
        'minutes': weekMinutes,
      });
    }

    return {
      'totalMinutes': totalMinutes,
      'averageRating': averageRating,
      'currentWeekMinutes': currentWeekMinutes,
      'emojiDistribution': emojiDistribution,
      'weeklyTrend': weeklyTrend,
    };
  }
}
