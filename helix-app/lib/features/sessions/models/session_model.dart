import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Session Model
class SessionModel {
  final String id;
  final String userId;
  final String activityId;
  final String activityName; // Denormalized for easier queries
  final Color activityColor; // Denormalized for display
  final int durationMinutes;
  final String emojiRating;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.activityName,
    required this.activityColor,
    required this.durationMinutes,
    required this.emojiRating,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  /// From Firebase Document
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      userId: data['userId'] as String,
      activityId: data['activityId'] as String,
      activityName: data['activityName'] as String,
      activityColor: Color(int.parse(data['activityColor'].substring(1), radix: 16) + 0xFF000000),
      durationMinutes: data['durationMinutes'] as int,
      emojiRating: data['emojiRating'] as String,
      notes: data['notes'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// To Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'activityId': activityId,
      'activityName': activityName,
      'activityColor': '#${activityColor.value.toRadixString(16).substring(2)}',
      'durationMinutes': durationMinutes,
      'emojiRating': emojiRating,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get duration in hours and minutes
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  /// Copy with
  SessionModel copyWith({
    String? id,
    String? userId,
    String? activityId,
    String? activityName,
    Color? activityColor,
    int? durationMinutes,
    String? emojiRating,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      activityColor: activityColor ?? this.activityColor,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      emojiRating: emojiRating ?? this.emojiRating,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
