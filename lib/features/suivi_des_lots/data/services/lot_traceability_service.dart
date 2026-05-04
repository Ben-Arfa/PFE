import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/create_lot_history_event_input.dart';
import '../../domain/entities/lot_history_event.dart';

class LotTraceabilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _events(String lotId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('lots')
        .doc(lotId)
        .collection('historyEvents');
  }

  Stream<List<LotHistoryEvent>> watchEvents(String lotId) {
    try {
      return _events(lotId)
          .orderBy('eventAt', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => LotHistoryEvent.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> addEvent(CreateLotHistoryEventInput input) async {
    await _events(input.lotId).add({
      'lotId': input.lotId,
      'type': input.type,
      'title': input.title,
      'description': input.description,
      'eventAt': Timestamp.fromDate(input.eventAt),
      'createdAt': FieldValue.serverTimestamp(),
      'metadata': input.metadata,
    });
  }
}
