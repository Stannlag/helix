import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../../auth/services/auth_service.dart';

/// Session Service for managing time tracking sessions in Firestore
class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Get sessions collection reference for a user
  CollectionReference _getSessionsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('sessions');
  }

  /// Create a new session
  Future<SessionModel> createSession(SessionModel session) async {
    try {
      final sessionWithId = session.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
      );

      await _getSessionsCollection(session.userId)
          .doc(sessionWithId.id)
          .set(sessionWithId.toFirestore());

      return sessionWithId;
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }

  /// Update a session
  Future<void> updateSession(SessionModel session) async {
    try {
      await _getSessionsCollection(session.userId)
          .doc(session.id)
          .update(session.toFirestore());
    } catch (e) {
      print('Error updating session: $e');
      rethrow;
    }
  }

  /// Delete a session
  Future<void> deleteSession(String userId, String sessionId) async {
    try {
      await _getSessionsCollection(userId).doc(sessionId).delete();
    } catch (e) {
      print('Error deleting session: $e');
      rethrow;
    }
  }

  /// Get all sessions for a user (stream)
  Stream<List<SessionModel>> getSessionsStream(String userId) {
    return _getSessionsCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  /// Get sessions for a specific date range
  Stream<List<SessionModel>> getSessionsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _getSessionsCollection(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  /// Get sessions for a specific day
  Stream<List<SessionModel>> getSessionsForDay(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return getSessionsForDateRange(userId, startOfDay, endOfDay);
  }

  /// Get sessions for a specific month
  Stream<List<SessionModel>> getSessionsForMonth(String userId, DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    return getSessionsForDateRange(userId, startOfMonth, endOfMonth);
  }

  /// Get single session
  Future<SessionModel?> getSession(String userId, String sessionId) async {
    try {
      final doc = await _getSessionsCollection(userId).doc(sessionId).get();
      if (doc.exists) {
        return SessionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting session: $e');
      return null;
    }
  }
}

/// Provider for SessionService
final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());

/// Provider for sessions stream
final sessionsStreamProvider = StreamProvider.autoDispose<List<SessionModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessionsStream(user.uid);
});

/// Provider for sessions for current month
final currentMonthSessionsProvider = StreamProvider.autoDispose<List<SessionModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);

  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessionsForMonth(user.uid, DateTime.now());
});
