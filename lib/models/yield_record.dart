class YieldRecord {
  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final double quantity;
  final String unit;
  final DateTime date;
  final String quality;
  final String? notes;
  final double? expectedYield;
  final double performancePercentage;
  final DateTime createdAt;

  YieldRecord({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.quantity,
    this.unit = 'tons',
    required this.date,
    required this.quality,
    this.notes,
    this.expectedYield,
    required this.performancePercentage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'quantity': quantity,
      'unit': unit,
      'date': date.millisecondsSinceEpoch,
      'quality': quality,
      'notes': notes,
      'expectedYield': expectedYield,
      'performancePercentage': performancePercentage,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory YieldRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return YieldRecord(
      id: id,
      userId: data['userId'] ?? '',
      cropId: data['cropId'] ?? '',
      cropName: data['cropName'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'tons',
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] ?? 0),
      quality: data['quality'] ?? 'Good',
      notes: data['notes'],
      expectedYield: data['expectedYield']?.toDouble(),
      performancePercentage: (data['performancePercentage'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  factory YieldRecord.fromMap(Map<String, dynamic> map) {
    return YieldRecord(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cropId: map['cropId'] ?? '',
      cropName: map['cropName'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'tons',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      quality: map['quality'] ?? 'Good',
      notes: map['notes'],
      expectedYield: map['expectedYield']?.toDouble(),
      performancePercentage: (map['performancePercentage'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  YieldRecord copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? cropName,
    double? quantity,
    String? unit,
    DateTime? date,
    String? quality,
    String? notes,
    double? expectedYield,
    double? performancePercentage,
    DateTime? createdAt,
  }) {
    return YieldRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
      expectedYield: expectedYield ?? this.expectedYield,
      performancePercentage: performancePercentage ?? this.performancePercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'YieldRecord(id: $id, cropName: $cropName, quantity: $quantity $unit, date: $date)';
  }
}