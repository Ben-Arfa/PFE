import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../gestions_des_lots_des_volailles/domain/entities/flock_lot.dart';
import '../../domain/inputs/create_daily_entry_input.dart';
import '../../domain/entities/daily_entry.dart';

class DailyEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _lotDoc(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId);
  }

  CollectionReference<Map<String, dynamic>> _dailyEntries(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId)
        .collection('dailyEntries');
  }

  Stream<List<DailyEntry>> watchEntries(String lotId) {
    try {
      return _dailyEntries(lotId)
          .orderBy('date', descending: false)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => DailyEntry.fromMap(d.id, d.data()))
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> createEntry(CreateDailyEntryInput input) async {
    final lotRef = _lotDoc(input.lotId);
    final lotSnapshot = await lotRef.get();
    if (!lotSnapshot.exists) throw Exception('Lot introuvable');

    final lot = FlockLot.fromMap(lotSnapshot.id, lotSnapshot.data() ?? {});

    final entryRef = _dailyEntries(input.lotId).doc();
    final batch = _firestore.batch();

    batch.set(entryRef, {
      'lotId': input.lotId,
      'date': Timestamp.fromDate(input.date),
      'deathsToday': input.deathsToday,
      'eggsToday': input.eggsToday,
      'avgWeightKg': input.avgWeightKg,
      'feedKg': input.feedKg,
      'waterL': input.waterL,
      'observations': input.observations,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // update lot currentBirdCount if there are deaths
    final newCount = (lot.currentBirdCount - input.deathsToday).clamp(
      0,
      lot.currentBirdCount,
    );
    batch.update(lotRef, {
      'currentBirdCount': newCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> deleteEntry(String lotId, String entryId) async {
    final ref = _dailyEntries(lotId).doc(entryId);
    await ref.delete();
  }
}
