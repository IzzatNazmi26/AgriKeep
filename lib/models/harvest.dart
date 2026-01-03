import 'package:cloud_firestore/cloud_firestore.dart';

class Harvest {
  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final DateTime harvestDate;
  final double quantityKg; // Always in kg
  final String? note; // Optional short note
  final DateTime createdAt;

  Harvest({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.harvestDate,
    required this.quantityKg,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'harvestDate': harvestDate.millisecondsSinceEpoch,
      'quantityKg': quantityKg,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Harvest.fromFirestore(String id, Map<String, dynamic> data) {
    return Harvest(
      id: id,
      userId: data['userId'] ?? '',
      cropId: data['cropId'] ?? '',
      cropName: data['cropName'] ?? '',
      harvestDate: DateTime.fromMillisecondsSinceEpoch(data['harvestDate'] ?? 0),
      quantityKg: (data['quantityKg'] ?? 0.0).toDouble(),
      note: data['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  factory Harvest.fromMap(Map<String, dynamic> map) {
    return Harvest(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cropId: map['cropId'] ?? '',
      cropName: map['cropName'] ?? '',
      harvestDate: DateTime.fromMillisecondsSinceEpoch(map['harvestDate'] ?? 0),
      quantityKg: (map['quantityKg'] ?? 0.0).toDouble(),
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Harvest copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? cropName,
    DateTime? harvestDate,
    double? quantityKg,
    String? note,
    DateTime? createdAt,
  }) {
    return Harvest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      harvestDate: harvestDate ?? this.harvestDate,
      quantityKg: quantityKg ?? this.quantityKg,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Harvest(id: $id, crop: $cropName, quantity: ${quantityKg}kg, date: $harvestDate)';
  }
}