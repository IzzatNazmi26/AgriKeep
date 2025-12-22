import 'package:flutter_test/flutter_test.dart';
import 'package:agrikeep/models/crop.dart';

void main() {
  group('Crop Model Tests', () {
    test('should create Crop from map', () {
      final map = {
        'id': '1',
        'name': 'Rice',
        'season': 'Kharif',
        'duration': '120-150 days',
        'waterRequirement': 'High',
        'soilType': ['Clay', 'Loamy'],
        'expectedYield': '4-6 tons/hectare',
        'marketPrice': 'RM400-500/ton',
        'category': 'Food Crop',
        'description': 'Staple food crop',
        'climate': 'Tropical',
        'tips': ['Tip 1', 'Tip 2'],
        'createdAt': 1672531200000, // Jan 1, 2023
      };

      final crop = Crop.fromMap(map);

      expect(crop.id, '1');
      expect(crop.name, 'Rice');
      expect(crop.season, 'Kharif');
      expect(crop.waterRequirement, 'High');
      expect(crop.soilType, ['Clay', 'Loamy']);
      expect(crop.expectedYield, '4-6 tons/hectare');
      expect(crop.marketPrice, 'RM400-500/ton');
      expect(crop.category, 'Food Crop');
      expect(crop.description, 'Staple food crop');
      expect(crop.climate, 'Tropical');
      expect(crop.tips, ['Tip 1', 'Tip 2']);
      expect(crop.createdAt?.year, 2023);
    });

    test('should convert Crop to map', () {
      final crop = Crop(
        id: '1',
        name: 'Rice',
        season: 'Kharif',
        duration: '120-150 days',
        waterRequirement: 'High',
        soilType: ['Clay', 'Loamy'],
        expectedYield: '4-6 tons/hectare',
        marketPrice: 'RM400-500/ton',
        category: 'Food Crop',
        description: 'Staple food crop',
        climate: 'Tropical',
        tips: ['Tip 1', 'Tip 2'],
        createdAt: DateTime(2023, 1, 1),
      );

      final map = crop.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Rice');
      expect(map['season'], 'Kharif');
      expect(map['waterRequirement'], 'High');
      expect(map['soilType'], ['Clay', 'Loamy']);
      expect(map['expectedYield'], '4-6 tons/hectare');
      expect(map['marketPrice'], 'RM400-500/ton');
      expect(map['category'], 'Food Crop');
      expect(map['description'], 'Staple food crop');
      expect(map['climate'], 'Tropical');
      expect(map['tips'], ['Tip 1', 'Tip 2']);
      expect(map['createdAt'], 1672531200000);
    });

    test('should create copy with updated values', () {
      final original = Crop(
        id: '1',
        name: 'Rice',
        season: 'Kharif',
        duration: '120-150 days',
        waterRequirement: 'High',
        soilType: ['Clay', 'Loamy'],
        expectedYield: '4-6 tons/hectare',
        marketPrice: 'RM400-500/ton',
        category: 'Food Crop',
      );

      final copy = original.copyWith(
        name: 'Wheat',
        season: 'Rabi',
        waterRequirement: 'Medium',
      );

      expect(copy.id, '1');
      expect(copy.name, 'Wheat');
      expect(copy.season, 'Rabi');
      expect(copy.waterRequirement, 'Medium');
      expect(copy.duration, '120-150 days');
      expect(copy.soilType, ['Clay', 'Loamy']);
      expect(copy.expectedYield, '4-6 tons/hectare');
      expect(copy.marketPrice, 'RM400-500/ton');
      expect(copy.category, 'Food Crop');
    });

    test('should compare Crop objects correctly', () {
      final crop1 = Crop(
        id: '1',
        name: 'Rice',
        season: 'Kharif',
        duration: '120-150 days',
        waterRequirement: 'High',
        soilType: ['Clay', 'Loamy'],
        expectedYield: '4-6 tons/hectare',
        marketPrice: 'RM400-500/ton',
        category: 'Food Crop',
      );

      final crop2 = Crop(
        id: '1',
        name: 'Wheat',
        season: 'Rabi',
        duration: '120-130 days',
        waterRequirement: 'Medium',
        soilType: ['Loamy'],
        expectedYield: '3-5 tons/hectare',
        marketPrice: 'RM300-400/ton',
        category: 'Food Crop',
      );

      final crop3 = Crop(
        id: '2',
        name: 'Rice',
        season: 'Kharif',
        duration: '120-150 days',
        waterRequirement: 'High',
        soilType: ['Clay', 'Loamy'],
        expectedYield: '4-6 tons/hectare',
        marketPrice: 'RM400-500/ton',
        category: 'Food Crop',
      );

      expect(crop1 == crop2, true); // Same ID
      expect(crop1 == crop3, false); // Different ID
      expect(crop1.hashCode == crop2.hashCode, true);
      expect(crop1.hashCode == crop3.hashCode, false);
    });

    test('should handle empty or null values', () {
      final map = {
        'id': '',
        'name': '',
        'season': '',
        'duration': '',
        'waterRequirement': '',
        'soilType': [],
        'expectedYield': '',
        'marketPrice': '',
        'category': '',
      };

      final crop = Crop.fromMap(map);

      expect(crop.id, '');
      expect(crop.name, '');
      expect(crop.season, '');
      expect(crop.duration, '');
      expect(crop.waterRequirement, '');
      expect(crop.soilType, []);
      expect(crop.expectedYield, '');
      expect(crop.marketPrice, '');
      expect(crop.category, '');
      expect(crop.description, null);
      expect(crop.climate, null);
      expect(crop.tips, null);
      expect(crop.createdAt, null);
    });
  });
}