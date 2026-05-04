import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/building_input.dart';

class BuildingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userBuildings() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('buildings');
  }

  CollectionReference<Map<String, dynamic>> _userLots() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('lots');
  }

  Future<bool> hasActiveLot(String buildingId) async {
    final snapshot = await _userLots()
        .where('buildingId', isEqualTo: buildingId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<List<Building>> watchBuildings() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _userBuildings()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Building.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Building>> watchAvailableBuildings() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _userBuildings()
        .where('status', isEqualTo: BuildingStatus.empty.value)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Building.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> createBuilding(BuildingInput input) async {
    final collection = _userBuildings();
    await collection.add({
      ...input.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBuilding(String id, BuildingInput input) async {
    final activeLot = await hasActiveLot(id);
    if (activeLot && input.status != BuildingStatus.active) {
      throw Exception(
        'Ce bâtiment est occupé par un lot actif. Fermez le lot avant de changer son statut.',
      );
    }

    await _userBuildings().doc(id).update({
      ...input.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBuilding(String id) async {
    final activeLot = await hasActiveLot(id);
    if (activeLot) {
      throw Exception(
        'Impossible de supprimer ce bâtiment tant qu\'un lot actif y est affecté.',
      );
    }

    await _userBuildings().doc(id).delete();
  }
}
