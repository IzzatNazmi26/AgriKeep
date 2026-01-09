class FarmProfile {
  final String id;
  final String userId;
  final String farmName;
  final String location;
  final double totalArea;
  final String soilType;
  final String irrigationType;
  final List<String> preferredCrops;
  final String? waterSource;
  //final String? sunlightExposure;

  final DateTime createdAt;
  final DateTime updatedAt;

  FarmProfile({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.location,
    required this.totalArea,
    required this.soilType,
    required this.irrigationType,
    this.preferredCrops = const [],
    this.waterSource,
    //this.sunlightExposure,

    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'farmName': farmName,
      'location': location,
      'totalArea': totalArea,
      'soilType': soilType,
      'irrigationType': irrigationType,
      'preferredCrops': preferredCrops,
      'waterSource': waterSource,
      //'sunlightExposure': sunlightExposure,

      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore
  factory FarmProfile.fromFirestore(String id, Map<String, dynamic> data) {
    return FarmProfile(
      id: id,
      userId: data['userId'] ?? '',
      farmName: data['farmName'] ?? '',
      location: data['location'] ?? '',
      totalArea: (data['totalArea'] ?? 0.0).toDouble(),
      soilType: data['soilType'] ?? '',
      irrigationType: data['irrigationType'] ?? '',
      preferredCrops: List<String>.from(data['preferredCrops'] ?? []),
      waterSource: data['waterSource'],
      //sunlightExposure: data['sunlightExposure'],

      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  // Create from Map
  factory FarmProfile.fromMap(Map<String, dynamic> map) {
    return FarmProfile(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      farmName: map['farmName'] ?? '',
      location: map['location'] ?? '',
      totalArea: (map['totalArea'] ?? 0.0).toDouble(),
      soilType: map['soilType'] ?? '',
      irrigationType: map['irrigationType'] ?? '',
      preferredCrops: List<String>.from(map['preferredCrops'] ?? []),
      waterSource: map['waterSource'],
      //sunlightExposure: map['sunlightExposure'],

      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  // Copy with method
  FarmProfile copyWith({
    String? id,
    String? userId,
    String? farmName,
    String? location,
    double? totalArea,
    String? soilType,
    String? irrigationType,
    List<String>? preferredCrops,
    String? waterSource,
    //String? sunlightExposure,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      totalArea: totalArea ?? this.totalArea,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      preferredCrops: preferredCrops ?? this.preferredCrops,
      waterSource: waterSource ?? this.waterSource,
      //sunlightExposure: sunlightExposure ?? this.sunlightExposure,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FarmProfile(id: $id, farmName: $farmName, location: $location, totalArea: $totalArea)';
  }
}