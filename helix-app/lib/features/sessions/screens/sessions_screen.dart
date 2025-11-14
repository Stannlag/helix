import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_service.dart';
import '../models/session_model.dart';
import '../widgets/session_card.dart';
import 'session_form_screen.dart';
import '../../../core/theme/app_colors.dart';

/// Sessions Screen - View all logged sessions
class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter by date',
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          // Apply date filter if set
          var filteredSessions = sessions;
          if (_filterStartDate != null && _filterEndDate != null) {
            filteredSessions = sessions.where((session) {
              final sessionDate = DateTime(
                session.date.year,
                session.date.month,
                session.date.day,
              );
              return sessionDate.isAfter(_filterStartDate!.subtract(const Duration(days: 1))) &&
                  sessionDate.isBefore(_filterEndDate!.add(const Duration(days: 1)));
            }).toList();
          }

          if (filteredSessions.isEmpty) {
            return _buildEmptyState(context, sessions.isNotEmpty);
          }

          // Group sessions by date
          final groupedSessions = _groupSessionsByDate(filteredSessions);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedSessions.length,
            itemBuilder: (context, index) {
              final entry = groupedSessions.entries.elementAt(index);
              final date = entry.key;
              final sessionsForDate = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                    child: Text(
                      _formatDateHeader(date),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),

                  // Sessions for this date
                  ...sessionsForDate.map((session) {
                    return SessionCard(
                      session: session,
                      onTap: () => _editSession(context, session),
                      onDelete: () => _deleteSession(context, ref, session),
                    );
                  }),
                ],
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
        onPressed: () => _createSession(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Session'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasFilteredResults) {
    if (hasFilteredResults) {
      // Has sessions but filtered out
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.filter_list_off,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                'No Sessions in Range',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'No sessions found for the selected\ndate range.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _filterStartDate = null;
                    _filterEndDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filter'),
              ),
            ],
          ),
        ),
      );
    }

    // No sessions at all
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
                Icons.history_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Sessions Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging your activities to\ntrack your progress!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
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

    // Sort by date (most recent first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return _formatDate(date);
    }
  }

  String _formatDate(DateTime date) {
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

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) => _FilterDialog(
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      ),
    );

    if (result != null) {
      setState(() {
        _filterStartDate = result['start'];
        _filterEndDate = result['end'];
      });
    }
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

/// Filter Dialog for date range selection
class _FilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const _FilterDialog({this.startDate, this.endDate});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.startDate;
    _end = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Date'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Start Date'),
            subtitle: Text(_start != null ? _formatDate(_start!) : 'Not set'),
            onTap: () => _pickDate(true),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('End Date'),
            subtitle: Text(_end != null ? _formatDate(_end!) : 'Not set'),
            onTap: () => _pickDate(false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, {'start': null, 'end': null});
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _start != null && _end != null
              ? () {
                  Navigator.pop(context, {'start': _start, 'end': _end});
                }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_start ?? DateTime.now())
          : (_end ?? _start ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (_end != null && _end!.isBefore(_start!)) {
            _end = _start;
          }
        } else {
          _end = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
