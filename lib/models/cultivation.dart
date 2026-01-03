
//this model is created during add new cultivation adjustment

import 'package:cloud_firestore/cloud_firestore.dart';

class Cultivation {
  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final DateTime plantingDate;
  final int growthDurationDays;
  final DateTime expectedHarvestDate;
  final String status; // "Planted", "Growing", "Harvested"
  final int currentDay; // days since planting
  final int progressPercentage; // (currentDay/growthDurationDays)*100
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cultivation({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.plantingDate,
    required this.growthDurationDays,
    required this.expectedHarvestDate,
    required this.status,
    required this.currentDay,
    required this.progressPercentage,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'plantingDate': plantingDate.millisecondsSinceEpoch,
      'growthDurationDays': growthDurationDays,
      'expectedHarvestDate': expectedHarvestDate.millisecondsSinceEpoch,
      'status': status,
      'currentDay': currentDay,
      'progressPercentage': progressPercentage,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Cultivation.fromFirestore(String id, Map<String, dynamic> data) {
    return Cultivation(
      id: id,
      userId: data['userId'] ?? '',
      cropId: data['cropId'] ?? '',
      cropName: data['cropName'] ?? '',
      plantingDate: DateTime.fromMillisecondsSinceEpoch(data['plantingDate'] ?? 0),
      growthDurationDays: data['growthDurationDays'] ?? 0,
      expectedHarvestDate: DateTime.fromMillisecondsSinceEpoch(data['expectedHarvestDate'] ?? 0),
      status: data['status'] ?? 'Planted',
      currentDay: data['currentDay'] ?? 0,
      progressPercentage: data['progressPercentage'] ?? 0,
      note: data['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  factory Cultivation.fromMap(Map<String, dynamic> map) {
    return Cultivation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cropId: map['cropId'] ?? '',
      cropName: map['cropName'] ?? '',
      plantingDate: DateTime.fromMillisecondsSinceEpoch(map['plantingDate'] ?? 0),
      growthDurationDays: map['growthDurationDays'] ?? 0,
      expectedHarvestDate: DateTime.fromMillisecondsSinceEpoch(map['expectedHarvestDate'] ?? 0),
      status: map['status'] ?? 'Planted',
      currentDay: map['currentDay'] ?? 0,
      progressPercentage: map['progressPercentage'] ?? 0,
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Cultivation copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? cropName,
    DateTime? plantingDate,
    int? growthDurationDays,
    DateTime? expectedHarvestDate,
    String? status,
    int? currentDay,
    int? progressPercentage,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cultivation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      plantingDate: plantingDate ?? this.plantingDate,
      growthDurationDays: growthDurationDays ?? this.growthDurationDays,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Cultivation(id: $id, cropName: $cropName, status: $status, progress: $progressPercentage%)';
  }
}