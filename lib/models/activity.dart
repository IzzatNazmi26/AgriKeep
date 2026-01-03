import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String cultivationId;
  final String activityType; // Planting, Watering, Fertilizer Application, etc.
  final DateTime activityDate;
  final String? fertilizerType; // Only if activityType == "Fertilizer Application"
  final String? wateringFrequency; // Only if activityType == "Watering"
  final String? note; // Optional short note
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.cultivationId,
    required this.activityType,
    required this.activityDate,
    this.fertilizerType,
    this.wateringFrequency,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cultivationId': cultivationId,
      'activityType': activityType,
      'activityDate': activityDate.millisecondsSinceEpoch,
      'fertilizerType': fertilizerType,
      'wateringFrequency': wateringFrequency,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Activity.fromFirestore(String id, Map<String, dynamic> data) {
    return Activity(
      id: id,
      userId: data['userId'] ?? '',
      cultivationId: data['cultivationId'] ?? '',
      activityType: data['activityType'] ?? '',
      activityDate: DateTime.fromMillisecondsSinceEpoch(data['activityDate'] ?? 0),
      fertilizerType: data['fertilizerType'],
      wateringFrequency: data['wateringFrequency'],
      note: data['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cultivationId: map['cultivationId'] ?? '',
      activityType: map['activityType'] ?? '',
      activityDate: DateTime.fromMillisecondsSinceEpoch(map['activityDate'] ?? 0),
      fertilizerType: map['fertilizerType'],
      wateringFrequency: map['wateringFrequency'],
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? cultivationId,
    String? activityType,
    DateTime? activityDate,
    String? fertilizerType,
    String? wateringFrequency,
    String? note,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cultivationId: cultivationId ?? this.cultivationId,
      activityType: activityType ?? this.activityType,
      activityDate: activityDate ?? this.activityDate,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, type: $activityType, date: $activityDate)';
  }
}