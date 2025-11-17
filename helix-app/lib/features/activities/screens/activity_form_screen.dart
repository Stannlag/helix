import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

/// Activity Form Screen - Create or Edit Activity
class ActivityFormScreen extends ConsumerStatefulWidget {
  final ActivityModel? activity;

  const ActivityFormScreen({super.key, this.activity});

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  Color _selectedColor = AppColors.activityColors[0];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _nameController.text = widget.activity!.name;
      _goalController.text = widget.activity!.goal ?? '';
      _selectedColor = widget.activity!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Activity' : 'New Activity'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Activity Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                hintText: 'e.g., Guitar Practice, Coding, Gym',
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an activity name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Color Picker
            Text(
              'Choose a Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildColorPicker(),

            const SizedBox(height: 24),

            // Goal (Optional)
            TextFormField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Goal (Optional)',
                hintText: 'e.g., Practice 30 min daily, 10 hours/week',
                prefixIcon: Icon(Icons.flag),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 32),

            // Preview Card
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
                onPressed: _isLoading ? null : _saveActivity,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(isEditing ? 'Update Activity' : 'Create Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppColors.activityColors.map((color) {
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 28,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textDisabled.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _selectedColor,
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
                  _nameController.text.isEmpty
                      ? 'Activity Name'
                      : _nameController.text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_goalController.text.isNotEmpty) ...[
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
                          _goalController.text,
                          style: Theme.of(context).textTheme.bodySmall,
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
        ],
      ),
    );
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User not signed in');
      }

      final activityService = ref.read(activityServiceProvider);

      if (widget.activity != null) {
        // Update existing activity
        final updatedActivity = widget.activity!.copyWith(
          name: _nameController.text.trim(),
          color: _selectedColor,
          goal: _goalController.text.trim().isEmpty
              ? null
              : _goalController.text.trim(),
        );
        await activityService.updateActivity(updatedActivity);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Create new activity
        final newActivity = ActivityModel(
          id: '', // Will be set by service
          userId: user.uid,
          name: _nameController.text.trim(),
          color: _selectedColor,
          goal: _goalController.text.trim().isEmpty
              ? null
              : _goalController.text.trim(),
          createdAt: DateTime.now(),
        );
        await activityService.createActivity(newActivity);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity created!'),
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
