import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../gestions_des_batiments/domain/entities/building.dart';
import '../../../gestion_des_types_des_volailles/domain/entities/poultry_type.dart';
import '../../domain/entities/close_lot_input.dart';
import '../../domain/entities/create_lot_input.dart';
import '../../domain/entities/flock_lot.dart';

class LotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userLots() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('lots');
  }

  CollectionReference<Map<String, dynamic>> _lotHistoryEvents(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId)
        .collection('historyEvents');
  }

  DocumentReference<Map<String, dynamic>> _buildingDoc(String buildingId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('buildings')
        .doc(buildingId);
  }

  Future<Building> _getBuilding(String buildingId) async {
    final snapshot = await _buildingDoc(buildingId).get();
    if (!snapshot.exists) {
      throw Exception('Bâtiment introuvable');
    }
    return Building.fromMap(snapshot.id, snapshot.data() ?? {});
  }

  Future<PoultryType> _getPoultryType(String poultryTypeId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('poultryTypes')
        .doc(poultryTypeId)
        .get();
    if (!snapshot.exists) {
      throw Exception('Type de volaille introuvable');
    }
    return PoultryType.fromMap(snapshot.id, snapshot.data() ?? {});
  }

  Future<bool> _hasActiveLotInBuilding(String buildingId) async {
    final snapshot = await _userLots()
        .where('buildingId', isEqualTo: buildingId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<List<FlockLot>> watchLots() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _userLots()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FlockLot.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> createLot(CreateLotInput input) async {
    final building = await _getBuilding(input.buildingId);
    final poultryType = await _getPoultryType(input.poultryTypeId);
    if (building.status != BuildingStatus.empty) {
      throw Exception('Le bâtiment sélectionné n\'est pas vide.');
    }
    if (await _hasActiveLotInBuilding(input.buildingId)) {
      throw Exception('Un lot actif existe déjà dans ce bâtiment.');
    }
    if (input.initialBirdCount > building.capacityMax) {
      throw Exception(
        'Le nombre de sujets dépasse la capacité maximale du bâtiment.',
      );
    }

    final lotRef = _userLots().doc();
    final createdAt = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    batch.set(lotRef, {
      'identifier': input.identifier,
      'buildingId': input.buildingId,
      'buildingName': input.buildingName,
      'poultryTypeId': input.poultryTypeId,
      'poultryTypeName': input.poultryTypeName,
      'entryDate': Timestamp.fromDate(input.entryDate),
      'initialBirdCount': input.initialBirdCount,
      'currentBirdCount': input.initialBirdCount,
      'isActive': true,
      'provenance': input.provenance,
      'createdAt': createdAt,
      'closedAt': null,
      'closedSubjectsOut': null,
      'closureReason': null,
      'finalAvgWeightKg': null,
      'totalEggProduction': null,
      'closureSummary': null,
    });

    batch.set(_lotHistoryEvents(lotRef.id).doc(), {
      'lotId': lotRef.id,
      'type': 'entry',
      'title': 'Entrée du lot',
      'description':
          'Lot ${input.identifier} créé dans le bâtiment ${input.buildingName}.',
      'eventAt': Timestamp.fromDate(input.entryDate),
      'createdAt': createdAt,
      'metadata': {
        'lotIdentifier': input.identifier,
        'buildingId': input.buildingId,
        'buildingName': input.buildingName,
        'poultryTypeId': input.poultryTypeId,
        'poultryTypeName': input.poultryTypeName,
        'initialBirdCount': input.initialBirdCount,
      },
    });

    batch.update(_buildingDoc(input.buildingId), {
      'status': BuildingStatus.active.value,
      'activeLotId': lotRef.id,
      'activePoultryTypeId': poultryType.id,
      'activePoultryTypeName': poultryType.name,
      'targetTempMin': poultryType.targetTempMin,
      'targetTempMax': poultryType.targetTempMax,
      'targetHumidityMin': poultryType.targetHumidityMin,
      'targetHumidityMax': poultryType.targetHumidityMax,
      'recommendedDensity': poultryType.recommendedDensity,
      'recommendedLightHours': poultryType.recommendedLightHours,
      'typicalDurationDays': poultryType.typicalDurationDays,
      'targetWeightKg': poultryType.targetWeightKg,
      'layStartAgeDays': poultryType.layStartAgeDays,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> closeLot(CloseLotInput input) async {
    final lotDoc = _userLots().doc(input.lotId);
    final snapshot = await lotDoc.get();
    if (!snapshot.exists) {
      throw Exception('Lot introuvable');
    }

    final lot = FlockLot.fromMap(snapshot.id, snapshot.data() ?? {});
    if (!lot.isActive) {
      throw Exception('Ce lot est déjà clôturé.');
    }

    final closureSummary = <String, dynamic>{
      'lotId': lot.id,
      'lotIdentifier': lot.identifier,
      'closureDate': Timestamp.fromDate(input.closureDate),
      'subjectsOut': input.subjectsOut,
      'closureReason': input.closureReason,
      'finalAvgWeightKg': input.finalAvgWeightKg,
      'totalEggProduction': input.totalEggProduction,
      'closedBirdCount': input.subjectsOut,
    };

    final batch = _firestore.batch();
    batch.update(lotDoc, {
      'isActive': false,
      'currentBirdCount': 0,
      'closedSubjectsOut': input.subjectsOut,
      'closureReason': input.closureReason,
      'finalAvgWeightKg': input.finalAvgWeightKg,
      'totalEggProduction': input.totalEggProduction,
      'closureSummary': closureSummary,
      'closedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_lotHistoryEvents(input.lotId).doc(), {
      'lotId': input.lotId,
      'type': 'closure',
      'title': 'Clôture du lot',
      'description': input.closureReason,
      'eventAt': Timestamp.fromDate(input.closureDate),
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': closureSummary,
    });

    batch.update(_buildingDoc(input.buildingId), {
      'status': BuildingStatus.empty.value,
      'activeLotId': null,
      'activePoultryTypeId': null,
      'activePoultryTypeName': null,
      'targetTempMin': null,
      'targetTempMax': null,
      'targetHumidityMin': null,
      'targetHumidityMax': null,
      'recommendedDensity': null,
      'recommendedLightHours': null,
      'typicalDurationDays': null,
      'targetWeightKg': null,
      'layStartAgeDays': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> deleteLot(String lotId) async {
    final lotDoc = _userLots().doc(lotId);
    final snapshot = await lotDoc.get();
    if (!snapshot.exists) {
      throw Exception('Lot introuvable');
    }

    // Delete subcollections safely in batches
    Future<void> deleteCollection(
      CollectionReference<Map<String, dynamic>> col,
    ) async {
      while (true) {
        final snap = await col.limit(200).get();
        if (snap.docs.isEmpty) break;
        final batch = _firestore.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snap.docs.length < 200) break;
      }
    }

    // Common lot subcollections
    await deleteCollection(lotDoc.collection('dailyEntries'));
    await deleteCollection(lotDoc.collection('vaccinationPlans'));
    await deleteCollection(lotDoc.collection('historyEvents'));
    await deleteCollection(lotDoc.collection('journal'));

    await lotDoc.delete();
  }
}
