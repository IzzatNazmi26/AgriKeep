class SalesRecord {
  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double totalAmount;
  final String? buyer;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  SalesRecord({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.quantity,
    this.unit = 'tons',
    required this.pricePerUnit,
    required this.totalAmount,
    this.buyer,
    required this.date,
    this.notes,
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
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'buyer': buyer,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SalesRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return SalesRecord(
      id: id,
      userId: data['userId'] ?? '',
      cropId: data['cropId'] ?? '',
      cropName: data['cropName'] ?? '',
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? 'tons',
      pricePerUnit: (data['pricePerUnit'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      buyer: data['buyer'],
      date: DateTime.fromMillisecondsSinceEpoch(data['date'] ?? 0),
      notes: data['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }

  factory SalesRecord.fromMap(Map<String, dynamic> map) {
    return SalesRecord(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cropId: map['cropId'] ?? '',
      cropName: map['cropName'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'tons',
      pricePerUnit: (map['pricePerUnit'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      buyer: map['buyer'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  SalesRecord copyWith({
    String? id,
    String? userId,
    String? cropId,
    String? cropName,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    double? totalAmount,
    String? buyer,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return SalesRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      totalAmount: totalAmount ?? this.totalAmount,
      buyer: buyer ?? this.buyer,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SalesRecord(id: $id, cropName: $cropName, totalAmount: RM$totalAmount, date: $date)';
  }
}
