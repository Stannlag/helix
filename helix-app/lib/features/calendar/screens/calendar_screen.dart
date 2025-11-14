import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../sessions/models/session_model.dart';
import '../../sessions/services/session_service.dart';
import '../../sessions/screens/session_form_screen.dart';
import '../../sessions/widgets/session_card.dart';
import '../../../core/theme/app_colors.dart';

/// Calendar Screen - View sessions in a calendar format
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Go to today',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          // Group sessions by date
          final sessionsByDate = _groupSessionsByDate(sessions);

          return Column(
            children: [
              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final dateKey = DateTime(day.year, day.month, day.day);
                    final sessionsForDay = sessionsByDate[dateKey];

                    if (sessionsForDay == null || sessionsForDay.isEmpty) {
                      return null;
                    }

                    return _buildDayMarker(sessionsForDay);
                  },
                ),
              ),

              const Divider(),

              // Selected day sessions
              Expanded(
                child: _selectedDay != null
                    ? _buildSelectedDaySessions(
                        sessionsByDate[
                            DateTime(_selectedDay!.year, _selectedDay!.month,
                                _selectedDay!.day)] ??
                            [])
                    : _buildNoDateSelected(),
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
              Text('Error loading sessions: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sessionsStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton.extended(
              onPressed: () => _createSession(context),
              icon: const Icon(Icons.add),
              label: const Text('Log Session'),
            )
          : null,
    );
  }

  Widget _buildDayMarker(List<SessionModel> sessions) {
    // Calculate total time and unique colors
    final colors = <Color>{};
    var totalMinutes = 0;

    for (final session in sessions) {
      colors.add(session.activityColor);
      totalMinutes += session.durationMinutes;
    }

    return Positioned(
      bottom: 1,
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: colors.length == 1
              ? null
              : LinearGradient(
                  colors: colors.toList(),
                  stops: List.generate(
                    colors.length,
                    (i) => i / (colors.length - 1),
                  ),
                ),
          color: colors.length == 1 ? colors.first : null,
        ),
      ),
    );
  }

  Widget _buildNoDateSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a day to view sessions',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDaySessions(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No sessions on ${_formatDate(_selectedDay!)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _createSession(context),
                icon: const Icon(Icons.add),
                label: const Text('Log Session'),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate total time
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with date and total time
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.textDisabled.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(_selectedDay!),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(totalMinutes),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sessions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return SessionCard(
                session: session,
                onTap: () => _editSession(context, session),
                onDelete: () => _deleteSession(context, ref, session),
              );
            },
          ),
        ),
      ],
    );
  }

  Map<DateTime, List<SessionModel>> _groupSessionsByDate(
      List<SessionModel> sessions) {
    final grouped = <DateTime, List<SessionModel>>{};

    for (final session in sessions) {
      final date = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(session);
    }

    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
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

  void _createSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SessionFormScreen(),
      ),
    );
  }

  void _editSession(BuildContext context, SessionModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionFormScreen(session: session),
      ),
    );
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    SessionModel session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete this ${session.activityName} session?',
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
        final sessionService = ref.read(sessionServiceProvider);
        await sessionService.deleteSession(session.userId, session.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting session: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
