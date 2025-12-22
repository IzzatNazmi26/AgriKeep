import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrikeep/models/farm_profile.dart';

class FarmProvider with ChangeNotifier {
  FarmProfile? _farmProfile;
  bool _isLoading = false;
  String? _error;

  FarmProfile? get farmProfile => _farmProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _farmProfile != null;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadFarmProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('farms')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _farmProfile = FarmProfile.fromFirestore(
          snapshot.docs.first.id,
          snapshot.docs.first.data(),
        );
      }
    } catch (e) {
      _error = 'Failed to load farm profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createFarmProfile(FarmProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final docRef = _firestore.collection('farms').doc();

      await docRef.set(profile.copyWith(
        id: docRef.id,
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap());

      _farmProfile = profile.copyWith(
        id: docRef.id,
        userId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _error = 'Failed to create farm profile';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFarmProfile(FarmProfile profile) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('farms').doc(profile.id).update(
        profile.copyWith(updatedAt: DateTime.now()).toMap(),
      );

      _farmProfile = profile.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      _error = 'Failed to update farm profile';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}