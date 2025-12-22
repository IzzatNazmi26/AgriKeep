import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/models/farm_profile.dart';
import 'package:agrikeep/models/yield_record.dart';
import 'package:agrikeep/models/sales_record.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Management
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(data);
    }
  }

  // Crop Management
  Future<List<Crop>> getCrops() async {
    final snapshot = await _firestore.collection('crops').get();
    return snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
  }

  Future<Crop?> getCropById(String id) async {
    final doc = await _firestore.collection('crops').doc(id).get();
    if (doc.exists) {
      return Crop.fromFirestore(doc);
    }
    return null;
  }

  // Farm Profile Management
  Future<FarmProfile?> getFarmProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('farms')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return FarmProfile.fromFirestore(
        snapshot.docs.first.id,
        snapshot.docs.first.data(),
      );
    }
    return null;
  }

  Future<void> saveFarmProfile(FarmProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('farms').doc(profile.id).set(
      profile.copyWith(
        userId: user.uid,
        updatedAt: DateTime.now(),
      ).toMap(),
    );
  }

  // Yield Records
  Future<List<YieldRecord>> getYieldRecords() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('yield_records')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => YieldRecord.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> addYieldRecord(YieldRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('yield_records').add(
      record.copyWith(userId: user.uid).toMap(),
    );
  }

  // Sales Records
  Future<List<SalesRecord>> getSalesRecords() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('sales_records')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => SalesRecord.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> addSalesRecord(SalesRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('sales_records').add(
      record.copyWith(userId: user.uid).toMap(),
    );
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics(String timeRange) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    // Calculate date range based on timeRange
    DateTime startDate;
    final now = DateTime.now();

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }

    // Get sales data
    final salesSnapshot = await _firestore
        .collection('sales_records')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .get();

    // Get yield data
    final yieldSnapshot = await _firestore
        .collection('yield_records')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .get();

    // Calculate analytics
    final totalRevenue = salesSnapshot.docs.fold<double>(0, (sum, doc) {
      final data = doc.data();
      return sum + (data['totalAmount'] ?? 0.0);
    });

    final totalYield = yieldSnapshot.docs.fold<double>(0, (sum, doc) {
      final data = doc.data();
      return sum + (data['quantity'] ?? 0.0);
    });

    return {
      'totalRevenue': totalRevenue,
      'totalYield': totalYield,
      'salesCount': salesSnapshot.docs.length,
      'yieldCount': yieldSnapshot.docs.length,
    };
  }
}