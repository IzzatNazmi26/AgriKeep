import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/models/recommendation_input.dart';
import 'package:agrikeep/utils/mock_data.dart';

class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  List<Crop> _recommendedCrops = [];
  bool _isLoading = false;
  String? _error;

  List<Crop> get crops => _crops;
  List<Crop> get recommendedCrops => _recommendedCrops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CropProvider() {
    // Load mock data initially
    _crops = MockData.mockCrops;
  }

  Future<void> loadCrops() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Try to load from Firestore first
      final snapshot = await _firestore.collection('crops').get();

      if (snapshot.docs.isNotEmpty) {
        // Load from Firestore
        _crops = snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
      } else {
        // Fall back to mock data
        _crops = MockData.mockCrops;
      }
    } catch (e) {
      // On error, use mock data
      _crops = MockData.mockCrops;
      _error = 'Using offline data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRecommendations(RecommendationInput input) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Filter crops based on input
      _recommendedCrops = _crops.where((crop) {

        // Match water requirement
        final waterMatch = crop.waterRequirement.toLowerCase() ==
            input.waterAvailability.toLowerCase();

        // Match soil type
        final soilMatch = crop.soilType.any((soil) =>
        soil.toLowerCase().contains(input.soilType.toLowerCase()) ||
            input.soilType.toLowerCase().contains(soil.toLowerCase()));

        return waterMatch && soilMatch;
      }).toList();


      // Limit to top 5 recommendations
      if (_recommendedCrops.length > 5) {
        _recommendedCrops = _recommendedCrops.sublist(0, 5);
      }

      // Sort by expected yield (highest first)
      _recommendedCrops.sort((a, b) {
        // Extract numbers from yield strings
        final yieldA = _extractYieldNumber(a.expectedYield);
        final yieldB = _extractYieldNumber(b.expectedYield);
        return yieldB.compareTo(yieldA);
      });
    } catch (e) {
      _error = 'Failed to get recommendations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _extractYieldNumber(String yieldString) {
    try {
      // Extract first number from string like "4-6 tons/hectare"
      final regex = RegExp(r'(\d+\.?\d*)');
      final match = regex.firstMatch(yieldString);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> saveCropToPlanned(Crop crop) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('planned_crops')
          .add({
        'cropId': crop.id,
        'cropName': crop.name,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'plannedForSeason': crop.season,
        'expectedYield': crop.expectedYield,
        'marketPrice': crop.marketPrice,
      });

      // Show success message
      _error = null;
    } catch (e) {
      _error = 'Failed to save crop to planned list';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Crop> searchCrops(String query) {
    if (query.isEmpty) return _crops;

    final lowerQuery = query.toLowerCase();
    return _crops.where((crop) {
      return crop.name.toLowerCase().contains(lowerQuery) ||
          crop.category.toLowerCase().contains(lowerQuery) ||
          crop.description?.toLowerCase().contains(lowerQuery) == true ||
          crop.season.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Crop> getCropsBySeason(String season) {
    return _crops.where((crop) => crop.season.toLowerCase().contains(season.toLowerCase())).toList();
  }

  List<Crop> getCropsByCategory(String category) {
    return _crops.where((crop) => crop.category.toLowerCase() == category.toLowerCase()).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearRecommendations() {
    _recommendedCrops.clear();
    notifyListeners();
  }

  void reset() {
    _crops = MockData.mockCrops;
    _recommendedCrops.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}