class RecommendationInput {
  String season;
  String soilType;
  String waterAvailability;
  double farmSize;
  String? previousCrop;
  String? plantingMonth;
  String? environmentType;
  String? currentSeason;
  String? sunlightExposure;

  RecommendationInput({
    required this.season,
    required this.soilType,
    required this.waterAvailability,
    required this.farmSize,
    this.previousCrop,
    this.plantingMonth,
    this.environmentType,
    this.currentSeason,
    this.sunlightExposure,
  });

  Map<String, dynamic> toMap() {
    return {
      'season': season,
      'soilType': soilType,
      'waterAvailability': waterAvailability,
      'farmSize': farmSize,
      'previousCrop': previousCrop,
      'plantingMonth': plantingMonth,
      'environmentType': environmentType,
      'currentSeason': currentSeason,
      'sunlightExposure': sunlightExposure,
    };
  }

  factory RecommendationInput.fromMap(Map<String, dynamic> map) {
    return RecommendationInput(
      season: map['season'] ?? '',
      soilType: map['soilType'] ?? '',
      waterAvailability: map['waterAvailability'] ?? '',
      farmSize: (map['farmSize'] ?? 0.0).toDouble(),
      previousCrop: map['previousCrop'],
      plantingMonth: map['plantingMonth'],
      environmentType: map['environmentType'],
      currentSeason: map['currentSeason'],
      sunlightExposure: map['sunlightExposure'],
    );
  }

  RecommendationInput copyWith({
    String? season,
    String? soilType,
    String? waterAvailability,
    double? farmSize,
    String? previousCrop,
    String? plantingMonth,
    String? environmentType,
    String? currentSeason,
    String? sunlightExposure,
  }) {
    return RecommendationInput(
      season: season ?? this.season,
      soilType: soilType ?? this.soilType,
      waterAvailability: waterAvailability ?? this.waterAvailability,
      farmSize: farmSize ?? this.farmSize,
      previousCrop: previousCrop ?? this.previousCrop,
      plantingMonth: plantingMonth ?? this.plantingMonth,
      environmentType: environmentType ?? this.environmentType,
      currentSeason: currentSeason ?? this.currentSeason,
      sunlightExposure: sunlightExposure ?? this.sunlightExposure,
    );
  }

  @override
  String toString() {
    return 'RecommendationInput(season: $season, soilType: $soilType, farmSize: $farmSize)';
  }
}