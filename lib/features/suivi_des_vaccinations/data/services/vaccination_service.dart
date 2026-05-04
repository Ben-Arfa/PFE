import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../domain/entities/vaccination_plan.dart';
import '../../domain/inputs/create_vaccination_plan_input.dart';
import '../../domain/inputs/record_vaccination_input.dart';
import 'vaccination_notification_service.dart';

class VaccinationService {
  VaccinationService({VaccinationNotificationService? notificationService})
    : _notificationService =
          notificationService ?? VaccinationNotificationService.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final VaccinationNotificationService _notificationService;

  CollectionReference<Map<String, dynamic>> _lots() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('lots');
  }

  DocumentReference<Map<String, dynamic>> _lotDoc(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId);
  }

  CollectionReference<Map<String, dynamic>> _plans(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId)
        .collection('vaccinationPlans');
  }

  CollectionReference<Map<String, dynamic>> _historyEvents(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId)
        .collection('historyEvents');
  }

  Stream<List<FlockLot>> watchActiveLots() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _lots().snapshots().map((snapshot) {
      final lots = snapshot.docs
          .map((doc) => FlockLot.fromMap(doc.id, doc.data()))
          .where((lot) => lot.isActive)
          .toList();
      lots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return lots;
    });
  }

  Stream<List<VaccinationPlan>> watchPlans(String lotId) {
    try {
      return _plans(lotId).snapshots().map((snapshot) {
        final plans = snapshot.docs
            .map((doc) => VaccinationPlan.fromMap(doc.id, doc.data()))
            .toList();
        plans.sort((a, b) => a.plannedDate.compareTo(b.plannedDate));
        return plans;
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> createPlan(CreateVaccinationPlanInput input) async {
    final lotSnapshot = await _lotDoc(input.lotId).get();
    if (!lotSnapshot.exists) {
      throw Exception('Lot introuvable');
    }

    final lot = FlockLot.fromMap(lotSnapshot.id, lotSnapshot.data() ?? {});
    if (!lot.isActive) {
      throw Exception('Le lot sélectionné n\'est pas actif.');
    }

    final planRef = _plans(input.lotId).doc();
    final batch = _firestore.batch();

    batch.set(planRef, {
      'lotId': input.lotId,
      'lotIdentifier': input.lotIdentifier,
      'buildingName': input.buildingName,
      'poultryTypeName': input.poultryTypeName,
      'plannedDate': Timestamp.fromDate(input.plannedDate),
      'vaccineName': input.vaccineName,
      'administrationRoute': input.administrationRoute,
      'dosePerSubject': input.dosePerSubject,
      'status': 'planned',
      'actualDate': null,
      'actualDosePerSubject': null,
      'vaccinatedSubjects': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_historyEvents(input.lotId).doc(), {
      'lotId': input.lotId,
      'type': 'vaccination_plan',
      'title': 'Vaccination planifiee',
      'description':
          '${input.vaccineName} - ${input.administrationRoute} - ${input.dosePerSubject} par sujet',
      'eventAt': Timestamp.fromDate(input.plannedDate),
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': {
        'planId': planRef.id,
        'lotIdentifier': input.lotIdentifier,
        'buildingName': input.buildingName,
        'poultryTypeName': input.poultryTypeName,
        'vaccineName': input.vaccineName,
        'administrationRoute': input.administrationRoute,
        'dosePerSubject': input.dosePerSubject,
      },
    });

    await batch.commit();

    await _notificationService.schedulePlanReminders(
      planId: planRef.id,
      lotIdentifier: input.lotIdentifier,
      vaccineName: input.vaccineName,
      administrationRoute: input.administrationRoute,
      plannedDate: input.plannedDate,
      dosePerSubject: input.dosePerSubject,
    );
  }

  Future<void> recordVaccination(RecordVaccinationInput input) async {
    final lotSnapshot = await _lotDoc(input.lotId).get();
    if (!lotSnapshot.exists) {
      throw Exception('Lot introuvable');
    }

    final planRef = _plans(input.lotId).doc(input.planId);
    final planSnapshot = await planRef.get();
    if (!planSnapshot.exists) {
      throw Exception('Calendrier vaccinal introuvable');
    }

    final plan = VaccinationPlan.fromMap(
      planSnapshot.id,
      planSnapshot.data() ?? {},
    );

    final batch = _firestore.batch();
    batch.update(planRef, {
      'status': 'completed',
      'actualDate': Timestamp.fromDate(input.actualDate),
      'actualDosePerSubject': input.actualDosePerSubject,
      'vaccinatedSubjects': input.vaccinatedSubjects,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_historyEvents(input.lotId).doc(), {
      'lotId': input.lotId,
      'type': 'vaccination',
      'title': 'Vaccination effectuee',
      'description':
          '${plan.vaccineName} - ${input.vaccinatedSubjects} sujets - ${input.actualDosePerSubject} par sujet',
      'eventAt': Timestamp.fromDate(input.actualDate),
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': {
        'planId': input.planId,
        'vaccineName': plan.vaccineName,
        'administrationRoute': plan.administrationRoute,
        'plannedDate': plan.plannedDate,
        'actualDosePerSubject': input.actualDosePerSubject,
        'vaccinatedSubjects': input.vaccinatedSubjects,
      },
    });

    await batch.commit();
    await _notificationService.cancelPlanReminders(input.planId);
  }
}
