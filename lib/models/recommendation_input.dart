class RecommendationInput {
  String soilType;
  String waterAvailability;
  double farmSize;
  String? previousCrop;
  String? plantingMonth;
  String? currentSeason;
  String? sunlightExposure;
  int? maxDurationDays; // ADD THIS

  RecommendationInput({
    required this.soilType,
    required this.waterAvailability,
    required this.farmSize,
    this.previousCrop,
    this.plantingMonth,
    this.currentSeason,
    this.sunlightExposure,
    this.maxDurationDays, // ADD THIS
  });

  Map<String, dynamic> toMap() {
    return {
      'soilType': soilType,
      'waterAvailability': waterAvailability,
      'farmSize': farmSize,
      'previousCrop': previousCrop,
      'plantingMonth': plantingMonth,
      'currentSeason': currentSeason,
      'sunlightExposure': sunlightExposure,
      'maxDurationDays': maxDurationDays, // ADD THIS
    };
  }

  factory RecommendationInput.fromMap(Map<String, dynamic> map) {
    return RecommendationInput(
      soilType: map['soilType'] ?? '',
      waterAvailability: map['waterAvailability'] ?? '',
      farmSize: (map['farmSize'] ?? 0.0).toDouble(),
      previousCrop: map['previousCrop'],
      plantingMonth: map['plantingMonth'],
      currentSeason: map['currentSeason'],
      sunlightExposure: map['sunlightExposure'],
      maxDurationDays: map['maxDurationDays'] != null ? (map['maxDurationDays'] as num).toInt() : null, // ADD THIS
    );
  }

  RecommendationInput copyWith({
    String? soilType,
    String? waterAvailability,
    double? farmSize,
    String? previousCrop,
    String? plantingMonth,
    String? currentSeason,
    String? sunlightExposure,
    int? maxDurationDays, // ADD THIS
  }) {
    return RecommendationInput(
      soilType: soilType ?? this.soilType,
      waterAvailability: waterAvailability ?? this.waterAvailability,
      farmSize: farmSize ?? this.farmSize,
      previousCrop: previousCrop ?? this.previousCrop,
      plantingMonth: plantingMonth ?? this.plantingMonth,
      currentSeason: currentSeason ?? this.currentSeason,
      sunlightExposure: sunlightExposure ?? this.sunlightExposure,
      maxDurationDays: maxDurationDays ?? this.maxDurationDays, // ADD THIS
    );
  }

  @override
  String toString() {
    return 'RecommendationInput(soilType: $soilType, waterAvailability: $waterAvailability, farmSize: $farmSize, maxDurationDays: $maxDurationDays)';
  }
}