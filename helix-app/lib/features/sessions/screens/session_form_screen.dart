import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../../activities/services/activity_service.dart';
import '../../activities/models/activity_model.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/emoji_ratings.dart';

/// Session Form Screen - Create or Edit Session
class SessionFormScreen extends ConsumerStatefulWidget {
  final SessionModel? session;

  const SessionFormScreen({super.key, this.session});

  @override
  ConsumerState<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends ConsumerState<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  final _notesController = TextEditingController();

  ActivityModel? _selectedActivity;
  String _selectedEmoji = EmojiRatings.happy;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      final hours = widget.session!.durationMinutes ~/ 60;
      final minutes = widget.session!.durationMinutes % 60;
      _hoursController.text = hours.toString();
      _minutesController.text = minutes.toString();
      _notesController.text = widget.session!.notes ?? '';
      _selectedEmoji = widget.session!.emojiRating;
      _selectedDate = widget.session!.date;
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.session != null;
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Session' : 'Log Session'),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return _buildNoActivitiesState();
          }

          // Set initial activity if not editing
          if (_selectedActivity == null && !isEditing) {
            _selectedActivity = activities.first;
          } else if (isEditing && _selectedActivity == null) {
            // Find the activity for this session
            _selectedActivity = activities.firstWhere(
              (a) => a.id == widget.session!.activityId,
              orElse: () => activities.first,
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Activity Selector
                _buildActivitySelector(activities),
                const SizedBox(height: 24),

                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 24),

                // Duration
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildDurationInput(),
                const SizedBox(height: 24),

                // Emoji Rating
                Text(
                  'How did it go?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildEmojiPicker(),
                const SizedBox(height: 24),

                // Notes (Optional)
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'How was the session? Any insights?',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 32),

                // Preview
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildPreviewCard(),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSession,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditing ? 'Update Session' : 'Log Session'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading activities: $error'),
        ),
      ),
    );
  }

  Widget _buildNoActivitiesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Activities',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Create an activity first before\nlogging sessions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelector(List<ActivityModel> activities) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textDisabled.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ActivityModel>(
          value: _selectedActivity,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: activities.map((activity) {
            return DropdownMenuItem(
              value: activity,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: activity.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(activity.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (activity) {
            setState(() => _selectedActivity = activity);
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textDisabled.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              _formatDate(_selectedDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today, ${_monthDay(date)}';
    } else if (sessionDate == yesterday) {
      return 'Yesterday, ${_monthDay(date)}';
    } else {
      return _monthDay(date);
    }
  }

  String _monthDay(DateTime date) {
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildDurationInput() {
    return Row(
      children: [
        // Hours
        Expanded(
          child: TextFormField(
            controller: _hoursController,
            decoration: const InputDecoration(
              labelText: 'Hours',
              hintText: '0',
              prefixIcon: Icon(Icons.access_time),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueFormatter(23),
            ],
            validator: (value) {
              if ((value == null || value.isEmpty) &&
                  _minutesController.text.isEmpty) {
                return 'Enter duration';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        // Minutes
        Expanded(
          child: TextFormField(
            controller: _minutesController,
            decoration: const InputDecoration(
              labelText: 'Minutes',
              hintText: '0',
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueFormatter(59),
            ],
            validator: (value) {
              if ((value == null || value.isEmpty) &&
                  _hoursController.text.isEmpty) {
                return 'Enter duration';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiPicker() {
    final emojis = [
      EmojiRatings.sad,
      EmojiRatings.neutral,
      EmojiRatings.happy,
      EmojiRatings.amazing,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: emojis.map((emoji) {
        final isSelected = emoji == _selectedEmoji;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmoji = emoji),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewCard() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final totalMinutes = hours * 60 + minutes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textDisabled.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedActivity?.color ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedActivity?.name ?? 'Select Activity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      totalMinutes > 0
                          ? _formatDuration(totalMinutes)
                          : 'Enter duration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                _selectedEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          if (_notesController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              _notesController.text,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
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

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate() || _selectedActivity == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User not signed in');
      }

      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final totalMinutes = hours * 60 + minutes;

      if (totalMinutes == 0) {
        throw Exception('Duration must be greater than 0');
      }

      final sessionService = ref.read(sessionServiceProvider);

      if (widget.session != null) {
        // Update existing session
        final updatedSession = widget.session!.copyWith(
          activityId: _selectedActivity!.id,
          activityName: _selectedActivity!.name,
          activityColor: _selectedActivity!.color,
          durationMinutes: totalMinutes,
          emojiRating: _selectedEmoji,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          date: _selectedDate,
        );
        await sessionService.updateSession(updatedSession);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Create new session
        final newSession = SessionModel(
          id: '', // Will be set by service
          userId: user.uid,
          activityId: _selectedActivity!.id,
          activityName: _selectedActivity!.name,
          activityColor: _selectedActivity!.color,
          durationMinutes: totalMinutes,
          emojiRating: _selectedEmoji,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          date: _selectedDate,
          createdAt: DateTime.now(),
        );
        await sessionService.createSession(newSession);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session logged!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Input formatter to limit max value
class _MaxValueFormatter extends TextInputFormatter {
  final int max;

  _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text);
    if (value == null || value > max) {
      return oldValue;
    }

    return newValue;
  }
}
