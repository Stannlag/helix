import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Activity Model
class ActivityModel {
  final String id;
  final String userId;
  final String name;
  final Color color;
  final String? goal;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    this.goal,
    required this.createdAt,
  });

  /// From Firebase Document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      color: Color(int.parse(data['colorHex'].substring(1), radix: 16) + 0xFF000000),
      goal: data['goal'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// To Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'colorHex': '#${color.value.toRadixString(16).substring(2)}',
      'goal': goal,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Color as hex string
  String get colorHex => '#${color.value.toRadixString(16).substring(2)}';

  /// Copy with
  ActivityModel copyWith({
    String? id,
    String? userId,
    String? name,
    Color? color,
    String? goal,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
