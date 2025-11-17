import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../sessions/models/session_model.dart';
import '../../sessions/services/session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/emoji_ratings.dart';

/// Dashboard Screen - Analytics and insights
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Week'; // Week or Month

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Period selector
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Week', label: Text('Week')),
                ButtonSegment(value: 'Month', label: Text('Month')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> selected) {
                setState(() => _selectedPeriod = selected.first);
              },
            ),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (allSessions) {
          // Filter sessions by selected period
          final filteredSessions = _filterSessionsByPeriod(allSessions);

          if (filteredSessions.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate analytics
          final analytics = _calculateAnalytics(filteredSessions);
          final streakData = _calculateStreak(allSessions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Streak card
              _buildStreakCard(
                streakData['currentStreak'] as int,
                streakData['longestStreak'] as int,
              ),
              const SizedBox(height: 16),

              // Total time card
              _buildTotalTimeCard(analytics['totalMinutes'] as int),
              const SizedBox(height: 24),

              // Time allocation chart
              _buildTimeAllocationChart(
                  analytics['activityBreakdown'] as Map<String, dynamic>),
              const SizedBox(height: 24),

              // Activity breakdown list
              _buildActivityBreakdown(
                  analytics['activityBreakdown'] as Map<String, dynamic>),
              const SizedBox(height: 24),

              // Emoji rating distribution
              _buildEmojiDistribution(
                  analytics['emojiDistribution'] as Map<String, int>),
              const SizedBox(height: 24),

              // Session count
              _buildSessionCount(filteredSessions.length),
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
              Text('Error loading data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sessionsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Data Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging sessions to see\nyour analytics!',
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

  Widget _buildStreakCard(int currentStreak, int longestStreak) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Current streak
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currentStreak',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    currentStreak == 1 ? 'day' : 'days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 80,
              color: AppColors.textDisabled.withOpacity(0.3),
            ),
            // Longest streak
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$longestStreak',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Longest Streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    longestStreak == 1 ? 'day' : 'days',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalTimeCard(int totalMinutes) {
    final hours = totalMinutes / 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Total Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hours >= 1 ? '${hours.toStringAsFixed(1)} hrs' : '$totalMinutes min',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedPeriod == 'Week' ? 'This Week' : 'This Month',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAllocationChart(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    var index = 0;

    breakdown.forEach((activityName, data) {
      final minutes = data['minutes'] as int;
      final color = data['color'] as Color;
      final percentage = data['percentage'] as double;

      sections.add(
        PieChartSectionData(
          color: color,
          value: minutes.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Allocation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBreakdown(Map<String, dynamic> breakdown) {
    if (breakdown.isEmpty) return const SizedBox.shrink();

    // Sort by time (descending)
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => (b.value['minutes'] as int)
          .compareTo(a.value['minutes'] as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Activity Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...sortedEntries.map((entry) {
              final activityName = entry.key;
              final data = entry.value;
              final minutes = data['minutes'] as int;
              final color = data['color'] as Color;
              final percentage = data['percentage'] as double;

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: Text(activityName),
                subtitle: Text(_formatDuration(minutes)),
                trailing: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildEmojiDistribution(Map<String, int> distribution) {
    if (distribution.isEmpty) return const SizedBox.shrink();

    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Session Ratings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEmojiStat(
                    EmojiRatings.sad, distribution[EmojiRatings.sad] ?? 0, total),
                _buildEmojiStat(EmojiRatings.neutral,
                    distribution[EmojiRatings.neutral] ?? 0, total),
                _buildEmojiStat(EmojiRatings.happy,
                    distribution[EmojiRatings.happy] ?? 0, total),
                _buildEmojiStat(EmojiRatings.amazing,
                    distribution[EmojiRatings.amazing] ?? 0, total),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiStat(String emoji, int count, int total) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 40),
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

  Widget _buildSessionCount(int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              '$count ${count == 1 ? 'Session' : 'Sessions'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<SessionModel> _filterSessionsByPeriod(List<SessionModel> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedPeriod == 'Week') {
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return sessions.where((session) {
        final sessionDate =
            DateTime(session.date.year, session.date.month, session.date.day);
        return sessionDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(today.add(const Duration(days: 1)));
      }).toList();
    } else {
      // Month
      final monthStart = DateTime(now.year, now.month, 1);
      return sessions.where((session) {
        final sessionDate =
            DateTime(session.date.year, session.date.month, session.date.day);
        return sessionDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(today.add(const Duration(days: 1)));
      }).toList();
    }
  }

  Map<String, int> _calculateStreak(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return {'currentStreak': 0, 'longestStreak': 0};
    }

    // Get unique dates with sessions (normalized to start of day)
    final sessionDates = sessions
        .map((session) => DateTime(
              session.date.year,
              session.date.month,
              session.date.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (most recent first)

    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // Check if there's a session today or yesterday (to allow for flexibility)
    final mostRecentSession = sessionDates.first;
    final daysSinceLastSession = todayNormalized.difference(mostRecentSession).inDays;

    if (daysSinceLastSession <= 1) {
      // Start counting from most recent session
      DateTime checkDate = mostRecentSession;

      for (final date in sessionDates) {
        final daysDiff = checkDate.difference(date).inDays;

        if (daysDiff == 0) {
          currentStreak++;
          checkDate = date;
        } else if (daysDiff == 1) {
          currentStreak++;
          checkDate = date;
        } else {
          break; // Streak broken
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;

    for (int i = 0; i < sessionDates.length - 1; i++) {
      final daysDiff = sessionDates[i].difference(sessionDates[i + 1]).inDays;

      if (daysDiff == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Longest streak should at least be as long as current streak
    longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  Map<String, dynamic> _calculateAnalytics(List<SessionModel> sessions) {
    var totalMinutes = 0;
    final activityMap = <String, Map<String, dynamic>>{};
    final emojiMap = <String, int>{};

    for (final session in sessions) {
      totalMinutes += session.durationMinutes;

      // Activity breakdown
      if (!activityMap.containsKey(session.activityName)) {
        activityMap[session.activityName] = {
          'minutes': 0,
          'color': session.activityColor,
        };
      }
      activityMap[session.activityName]!['minutes'] =
          (activityMap[session.activityName]!['minutes'] as int) +
              session.durationMinutes;

      // Emoji distribution
      emojiMap[session.emojiRating] =
          (emojiMap[session.emojiRating] ?? 0) + 1;
    }

    // Calculate percentages
    activityMap.forEach((key, value) {
      value['percentage'] =
          totalMinutes > 0 ? (value['minutes'] / totalMinutes * 100) : 0;
    });

    return {
      'totalMinutes': totalMinutes,
      'activityBreakdown': activityMap,
      'emojiDistribution': emojiMap,
    };
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours hr';
    }
    return '$hours hr $mins min';
  }
}
