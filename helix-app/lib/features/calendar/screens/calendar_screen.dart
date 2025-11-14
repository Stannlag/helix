import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sessions/models/session_model.dart';
import '../../sessions/services/session_service.dart';
import '../../sessions/screens/session_form_screen.dart';
import '../../sessions/widgets/session_card.dart';
import '../../../core/theme/app_colors.dart';

/// Calendar Screen - Main view with Week/Month toggle
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isWeekView = true; // true = Week, false = Month
  DateTime _focusedWeek = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
      ),
      body: sessionsAsync.when(
        data: (sessions) => Column(
          children: [
            // Toggle Week/Month
            _buildViewToggle(),
            const SizedBox(height: 8),

            // Calendar (Week or Month)
            _isWeekView
                ? _buildWeekView(sessions)
                : _buildMonthView(sessions),

            const Divider(height: 1),

            // Selected Day Sessions
            Expanded(
              child: _buildSelectedDaySessions(sessions),
            ),
          ],
        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _logSession(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Session'),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('Week')),
          ButtonSegment(value: false, label: Text('Month')),
        ],
        selected: {_isWeekView},
        onSelectionChanged: (Set<bool> selected) {
          setState(() => _isWeekView = selected.first);
        },
      ),
    );
  }

  Widget _buildWeekView(List<SessionModel> sessions) {
    final weekStart = _getWeekStart(_focusedWeek);
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        // Week navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedWeek = _focusedWeek.subtract(const Duration(days: 7));
                  });
                },
              ),
              Text(
                _formatWeekRange(weekStart),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedWeek = _focusedWeek.add(const Duration(days: 7));
                  });
                },
              ),
            ],
          ),
        ),

        // Week columns
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: weekDays.map((day) {
                return Expanded(
                  child: _buildDayColumn(day, sessions),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(DateTime day, List<SessionModel> allSessions) {
    final dayDate = DateTime(day.year, day.month, day.day);
    final selectedDate = _selectedDay != null
        ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : null;
    final isSelected = dayDate == selectedDate;
    final isToday = dayDate == DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Get sessions for this day
    final daySessions = allSessions.where((session) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      return sessionDate == dayDate;
    }).toList();

    // Calculate total duration and proportions
    final totalMinutes = daySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDay = day);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Day label
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    _getDayName(day.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday ? AppColors.primary : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),

            // Activity blocks
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: daySessions.isEmpty
                    ? const SizedBox()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          children: daySessions.map((session) {
                            final heightPercent = totalMinutes > 0
                                ? (session.durationMinutes / totalMinutes)
                                : 0.0;
                            return Expanded(
                              flex: (heightPercent * 100).round(),
                              child: Container(
                                color: session.activityColor,
                                margin: const EdgeInsets.symmetric(vertical: 0.5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView(List<SessionModel> sessions) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    int firstWeekday = firstDayOfMonth.weekday;

    // Calculate total cells needed
    final totalCells = firstWeekday - 1 + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              Text(
                _formatMonthYear(_focusedMonth),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
        ),

        // Month grid
        SizedBox(
          height: weeks * 80.0 + 30, // Dynamic height based on weeks
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                // Week day headers
                Row(
                  children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Calendar grid
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: totalCells,
                    itemBuilder: (context, index) {
                      // Calculate if this is a valid day or empty cell
                      final dayNumber = index - (firstWeekday - 2);
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox();
                      }

                      final day = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                      return _buildMonthDayCell(day, sessions);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthDayCell(DateTime day, List<SessionModel> allSessions) {
    final dayDate = DateTime(day.year, day.month, day.day);
    final selectedDate = _selectedDay != null
        ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
        : null;
    final isSelected = dayDate == selectedDate;
    final isToday = dayDate == DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Get sessions for this day
    final daySessions = allSessions.where((session) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      return sessionDate == dayDate;
    }).toList();

    final totalMinutes = daySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDay = day);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textDisabled.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Day number
            Padding(
              padding: const EdgeInsets.all(2),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Activity blocks
            Expanded(
              child: daySessions.isEmpty
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Column(
                          children: daySessions.map((session) {
                            final heightPercent = totalMinutes > 0
                                ? (session.durationMinutes / totalMinutes)
                                : 0.0;
                            return Expanded(
                              flex: (heightPercent * 100).round(),
                              child: Container(
                                color: session.activityColor,
                                margin: const EdgeInsets.symmetric(vertical: 0.25),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDaySessions(List<SessionModel> allSessions) {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Select a day to view sessions'),
      );
    }

    final selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final daySessions = allSessions.where((session) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      return sessionDate == selectedDate;
    }).toList();

    final totalMinutes = daySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final dayName = _formatSelectedDayName(_selectedDay!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                dayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (totalMinutes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
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
          child: daySessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sessions logged',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: daySessions.length,
                  itemBuilder: (context, index) {
                    final session = daySessions[index];
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

  // Helper methods
  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _getDayName(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (weekStart.month == weekEnd.month) {
      return '${months[weekStart.month - 1]} ${weekStart.day} - ${weekEnd.day}, ${weekStart.year}';
    } else {
      return '${months[weekStart.month - 1]} ${weekStart.day} - ${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekStart.year}';
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDayName(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayDate = DateTime(day.year, day.month, day.day);

    if (dayDate == today) {
      return "Today's Sessions";
    } else if (dayDate == yesterday) {
      return "Yesterday's Sessions";
    } else {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${weekdays[day.weekday - 1]}'s Sessions (${months[day.month - 1]} ${day.day})";
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

  void _logSession(BuildContext context) {
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
