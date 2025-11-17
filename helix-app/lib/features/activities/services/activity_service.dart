import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_model.dart';
import '../../auth/services/auth_service.dart';

/// Activity Service for managing activities in Firestore
class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Get activities collection reference for a user
  CollectionReference _getActivitiesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('activities');
  }

  /// Create a new activity
  Future<ActivityModel> createActivity(ActivityModel activity) async {
    try {
      final activityWithId = activity.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
      );

      await _getActivitiesCollection(activity.userId)
          .doc(activityWithId.id)
          .set(activityWithId.toFirestore());

      return activityWithId;
    } catch (e) {
      print('Error creating activity: $e');
      rethrow;
    }
  }

  /// Update an activity
  Future<void> updateActivity(ActivityModel activity) async {
    try {
      await _getActivitiesCollection(activity.userId)
          .doc(activity.id)
          .update(activity.toFirestore());
    } catch (e) {
      print('Error updating activity: $e');
      rethrow;
    }
  }

  /// Delete an activity
  Future<void> deleteActivity(String userId, String activityId) async {
    try {
      await _getActivitiesCollection(userId).doc(activityId).delete();
    } catch (e) {
      print('Error deleting activity: $e');
      rethrow;
    }
  }

  /// Get all activities for a user (stream)
  Stream<List<ActivityModel>> getActivitiesStream(String userId) {
    return _getActivitiesCollection(userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromFirestore(doc))
            .toList());
  }

  /// Get single activity
  Future<ActivityModel?> getActivity(String userId, String activityId) async {
    try {
      final doc = await _getActivitiesCollection(userId).doc(activityId).get();
      if (doc.exists) {
        return ActivityModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting activity: $e');
      return null;
    }
  }
}

/// Provider for ActivityService
final activityServiceProvider = Provider<ActivityService>((ref) => ActivityService());

/// Provider for activities stream
final activitiesStreamProvider = StreamProvider.autoDispose<List<ActivityModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final activityService = ref.watch(activityServiceProvider);
  return activityService.getActivitiesStream(user.uid);
});
