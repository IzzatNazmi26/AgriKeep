import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrikeep/models/crop.dart';
import 'package:agrikeep/models/farm_profile.dart';
import 'package:agrikeep/models/yield_record.dart';
import 'package:agrikeep/models/sales_record.dart';
import 'package:agrikeep/models/harvest.dart';
import 'package:agrikeep/models/cultivation.dart';
import 'package:agrikeep/models/activity.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== ACTIVITY MANAGEMENT ==========
  Future<List<Activity>> getActivitiesByCultivationId(String cultivationId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .where('cultivationId', isEqualTo: cultivationId)
        .orderBy('activityDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Activity.fromFirestore(doc.id, doc.data());
    }).toList();
  }

  Future<Activity?> getActivityById(String activityId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('activities')
        .doc(activityId)
        .get();

    if (doc.exists) {
      return Activity.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }

  Future<void> updateActivity(Activity activity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('activities')
        .doc(activity.id)
        .update(activity.copyWith(userId: user.uid).toMap());
  }

  Future<void> deleteActivity(String activityId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('activities').doc(activityId).delete();
  }

  Future<void> deleteActivitiesByCultivationId(String cultivationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .where('cultivationId', isEqualTo: cultivationId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ========== HARVEST MANAGEMENT (Add delete by cultivation) ==========
  Future<void> deleteHarvestsByCultivationId(String cultivationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('harvests')
        .where('userId', isEqualTo: user.uid)
        .where('cultivationId', isEqualTo: cultivationId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ========== CULTIVATION MANAGEMENT ==========
  Future<List<Cultivation>> getCultivations() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('cultivations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('plantingDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Cultivation.fromFirestore(doc.id, data ?? {});
    }).toList();
  }

  Future<Cultivation?> getCultivationById(String id) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('cultivations')
        .doc(id)
        .get();

    if (doc.exists) {
      final data = doc.data();
      return Cultivation.fromFirestore(doc.id, data ?? {});
    }
    return null;
  }

  Future<void> addCultivation(Cultivation cultivation) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('cultivations').doc(cultivation.id).set(
      cultivation.copyWith(userId: user.uid).toMap(),
    );
  }

  Future<void> updateCultivation(Cultivation cultivation) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('cultivations')
        .doc(cultivation.id)
        .update({
      'cropId': cultivation.cropId,
      'cropName': cultivation.cropName,
      'plantingDate': cultivation.plantingDate.millisecondsSinceEpoch,
      'growthDurationDays': cultivation.growthDurationDays,
      'expectedHarvestDate': cultivation.expectedHarvestDate.millisecondsSinceEpoch,
      'status': cultivation.status,
      'currentDay': cultivation.currentDay,
      'progressPercentage': cultivation.progressPercentage,
      'note': cultivation.note,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteCultivation(String cultivationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Delete cultivation
    await _firestore.collection('cultivations').doc(cultivationId).delete();

    // Delete related activities
    await deleteActivitiesByCultivationId(cultivationId);

    // Delete related harvests
    await deleteHarvestsByCultivationId(cultivationId);
  }

  Future<List<Cultivation>> getActiveCultivations() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('cultivations')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['Planted', 'Growing', 'Flowering'])
        .orderBy('plantingDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Cultivation.fromFirestore(doc.id, data ?? {});
    }).toList();
  }

  Future<int> getActiveCultivationsCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final snapshot = await _firestore
        .collection('cultivations')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['Planted', 'Growing', 'Flowering'])
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // ========== HARVEST MANAGEMENT ==========
  Future<List<Harvest>> getHarvests() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('harvests')
        .where('userId', isEqualTo: user.uid)
        .orderBy('harvestDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => Harvest.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<List<Harvest>> getHarvestsByCultivationId(String cultivationId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('harvests')
        .where('userId', isEqualTo: user.uid)
        .where('cultivationId', isEqualTo: cultivationId)
        .orderBy('harvestDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => Harvest.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<List<Harvest>> getHarvestsByCropId(String cropId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('harvests')
        .where('userId', isEqualTo: user.uid)
        .where('cropId', isEqualTo: cropId)
        .orderBy('harvestDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => Harvest.fromFirestore(doc.id, doc.data())).toList();
  }

  Future<void> addHarvest(Harvest harvest) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('harvests').doc(harvest.id).set(
      harvest.copyWith(userId: user.uid).toMap(),
    );
  }

  Future<void> updateHarvest(Harvest harvest) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('harvests')
        .doc(harvest.id)
        .update(harvest.copyWith(userId: user.uid).toMap());
  }

  Future<void> deleteHarvest(String harvestId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('harvests').doc(harvestId).delete();
  }

  Future<double> getTotalHarvestedWeight() async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final snapshot = await _firestore
        .collection('harvests')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.fold<double>(0.0, (sum, doc) {
      final data = doc.data();
      return sum + (data['quantityKg'] ?? 0.0);
    });
  }

  Future<Map<String, dynamic>> getCropHarvestSummary(String cropId) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection('harvests')
        .where('userId', isEqualTo: user.uid)
        .where('cropId', isEqualTo: cropId)
        .get();

    final harvests = snapshot.docs.map((doc) => Harvest.fromFirestore(doc.id, doc.data())).toList();

    final totalQuantity = harvests.fold<double>(0.0, (sum, harvest) => sum + harvest.quantityKg);
    final count = harvests.length;
    final firstHarvest = harvests.isNotEmpty ? harvests.last.harvestDate : null;
    final lastHarvest = harvests.isNotEmpty ? harvests.first.harvestDate : null;

    return {
      'totalQuantity': totalQuantity,
      'count': count,
      'firstHarvest': firstHarvest,
      'lastHarvest': lastHarvest,
      'averagePerHarvest': count > 0 ? totalQuantity / count : 0.0,
    };
  }

  Future<void> updateCultivationStatus(String cultivationId, String status) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('cultivations')
        .doc(cultivationId)
        .update({
      'status': status,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ========== USER MANAGEMENT ==========
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(data);
    }
  }

  // ========== CROP MANAGEMENT ==========
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

  // ========== FARM PROFILE MANAGEMENT ==========
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

  // ========== SALES RECORDS ==========
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

  Future<void> updateSalesRecord(SalesRecord record) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('sales_records')
        .doc(record.id)
        .update(record.copyWith(userId: user.uid).toMap());
  }

  Future<void> deleteSalesRecord(String recordId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('sales_records').doc(recordId).delete();
  }

  Future<SalesRecord?> getSalesRecordById(String recordId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('sales_records')
        .doc(recordId)
        .get();

    if (doc.exists) {
      return SalesRecord.fromFirestore(doc.id, doc.data()!);
    }
    return null;
  }

  // ========== ANALYTICS ==========
  Future<Map<String, dynamic>> getAnalytics(String timeRange) async {
    final user = _auth.currentUser;
    if (user == null) return {};

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

    final salesSnapshot = await _firestore
        .collection('sales_records')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .get();

    final totalRevenue = salesSnapshot.docs.fold<double>(0, (sum, doc) {
      final data = doc.data();
      return sum + (data['totalAmount'] ?? 0.0);
    });

    return {
      'totalRevenue': totalRevenue,
      'salesCount': salesSnapshot.docs.length,
    };
  }
}