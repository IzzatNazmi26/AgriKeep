import 'package:cloud_firestore/cloud_firestore.dart';

class Crop {
  final String id;
  final String name;
  final String season;
  final String duration;
  final String waterRequirement;
  final List<String> soilType;
  final String expectedYield;
  final String marketPrice;
  final String category;
  final String? description;
  final String? climate;
  final List<String>? tips;
  final DateTime? createdAt;

  Crop({
    required this.id,
    required this.name,
    required this.season,
    required this.duration,
    required this.waterRequirement,
    required this.soilType,
    required this.expectedYield,
    required this.marketPrice,
    required this.category,
    this.description,
    this.climate,
    this.tips,
    this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'season': season,
      'duration': duration,
      'waterRequirement': waterRequirement,
      'soilType': soilType,
      'expectedYield': expectedYield,
      'marketPrice': marketPrice,
      'category': category,
      'description': description,
      'climate': climate,
      'tips': tips,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Create from Firestore Document
  factory Crop.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Crop(
      id: doc.id,
      name: data['name'] ?? '',
      season: data['season'] ?? '',
      duration: data['duration'] ?? '',
      waterRequirement: data['waterRequirement'] ?? '',
      soilType: List<String>.from(data['soilType'] ?? []),
      expectedYield: data['expectedYield'] ?? '',
      marketPrice: data['marketPrice'] ?? '',
      category: data['category'] ?? '',
      description: data['description'],
      climate: data['climate'],
      tips: data['tips'] != null ? List<String>.from(data['tips']) : null,
      createdAt: data['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(data['createdAt']) : null,
    );
  }

  // Create from Map
  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      season: map['season'] ?? '',
      duration: map['duration'] ?? '',
      waterRequirement: map['waterRequirement'] ?? '',
      soilType: List<String>.from(map['soilType'] ?? []),
      expectedYield: map['expectedYield'] ?? '',
      marketPrice: map['marketPrice'] ?? '',
      category: map['category'] ?? '',
      description: map['description'],
      climate: map['climate'],
      tips: map['tips'] != null ? List<String>.from(map['tips']) : null,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) : null,
    );
  }

  // Copy with method
  Crop copyWith({
    String? id,
    String? name,
    String? season,
    String? duration,
    String? waterRequirement,
    List<String>? soilType,
    String? expectedYield,
    String? marketPrice,
    String? category,
    String? description,
    String? climate,
    List<String>? tips,
    DateTime? createdAt,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      season: season ?? this.season,
      duration: duration ?? this.duration,
      waterRequirement: waterRequirement ?? this.waterRequirement,
      soilType: soilType ?? this.soilType,
      expectedYield: expectedYield ?? this.expectedYield,
      marketPrice: marketPrice ?? this.marketPrice,
      category: category ?? this.category,
      description: description ?? this.description,
      climate: climate ?? this.climate,
      tips: tips ?? this.tips,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Crop(id: $id, name: $name, season: $season, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Crop && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ... existing properties ...

  // Add this method at the end of the class (before the last closing brace)

  /// Extract maximum days from duration string like '75–90 days'
  /// Returns the higher number (90) for filtering

  int get maxDurationDays {
    try {
      final cleanDuration = duration.split('(').first.trim();
      final cleanDuration2 = cleanDuration.replaceAll(' days', '').replaceAll('–', '-');
      final parts = cleanDuration2.split('-');

      if (parts.length == 2) {
        final minDays = int.tryParse(parts[0].trim()) ?? 0;
        final maxDays = int.tryParse(parts[1].trim()) ?? 0;
        return maxDays > minDays ? maxDays : minDays;
      } else if (parts.length == 1) {
        return int.tryParse(parts[0].trim()) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  int get minDurationDays {
    try {
      final cleanDuration = duration.split('(').first.trim();
      final cleanDuration2 = cleanDuration.replaceAll(' days', '').replaceAll('–', '-');
      final parts = cleanDuration2.split('-');

      if (parts.length == 2) {
        return int.tryParse(parts[0].trim()) ?? 0;
      } else if (parts.length == 1) {
        return int.tryParse(parts[0].trim()) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}


