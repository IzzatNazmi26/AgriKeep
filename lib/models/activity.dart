import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String cultivationId;
  final String activityType;
  final DateTime date;
  final String? fertilizerType;
  final String? fertilizerAmount;
  final String? wateringFrequency;
  final String? pestIssues;
  final String? diseaseNotes;
  final String? generalNotes;
  final List<String>? photoUrls;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    required this.cultivationId,
    required this.activityType,
    required this.date,
    this.fertilizerType,
    this.fertilizerAmount,
    this.wateringFrequency,
    this.pestIssues,
    this.diseaseNotes,
    this.generalNotes,
    this.photoUrls,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cultivationId': cultivationId,
      'activityType': activityType,
      'date': date.millisecondsSinceEpoch,
      'fertilizerType': fertilizerType,
      'fertilizerAmount': fertilizerAmount,
      'wateringFrequency': wateringFrequency,
      'pestIssues': pestIssues,
      'diseaseNotes': diseaseNotes,
      'generalNotes': generalNotes,
      'photoUrls': photoUrls,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Activity.fromFirestore(String id, Map<String, dynamic> data) {
    return Activity(
      id: id,
      userId: data['userId'] ?? '',
      cultivationId: data['cultivationId'] ?? '',
      activityType: data['activityType'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] ?? 0),
      fertilizerType: data['fertilizerType'],
      fertilizerAmount: data['fertilizerAmount'],
      wateringFrequency: data['wateringFrequency'],
      pestIssues: data['pestIssues'],
      diseaseNotes: data['diseaseNotes'],
      generalNotes: data['generalNotes'],
      photoUrls: data['photoUrls'] != null
          ? List<String>.from(data['photoUrls'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cultivationId: map['cultivationId'] ?? '',
      activityType: map['activityType'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      fertilizerType: map['fertilizerType'],
      fertilizerAmount: map['fertilizerAmount'],
      wateringFrequency: map['wateringFrequency'],
      pestIssues: map['pestIssues'],
      diseaseNotes: map['diseaseNotes'],
      generalNotes: map['generalNotes'],
      photoUrls: map['photoUrls'] != null
          ? List<String>.from(map['photoUrls'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? cultivationId,
    String? activityType,
    DateTime? date,
    String? fertilizerType,
    String? fertilizerAmount,
    String? wateringFrequency,
    String? pestIssues,
    String? diseaseNotes,
    String? generalNotes,
    List<String>? photoUrls,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cultivationId: cultivationId ?? this.cultivationId,
      activityType: activityType ?? this.activityType,
      date: date ?? this.date,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      fertilizerAmount: fertilizerAmount ?? this.fertilizerAmount,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      pestIssues: pestIssues ?? this.pestIssues,
      diseaseNotes: diseaseNotes ?? this.diseaseNotes,
      generalNotes: generalNotes ?? this.generalNotes,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, type: $activityType, date: $date)';
  }
}