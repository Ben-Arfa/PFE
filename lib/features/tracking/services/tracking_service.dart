import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/tracking_models.dart';

class TrackingService {
  TrackingService._();
  static final instance = TrackingService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _uid;
    if (uid == null) {
      throw Exception('Utilisateur non connecte');
    }
    return _db.collection('users').doc(uid).collection('tracking');
  }

  Stream<List<TrackingEntry>> watchByKind(TrackingKind kind) {
    return _collection.where('kind', isEqualTo: kind.name).snapshots().map((
      snap,
    ) {
      final items = snap.docs
          .map((doc) => TrackingEntry.fromMap(doc.id, doc.data()))
          .toList();
      items.sort((a, b) => b.date.compareTo(a.date));
      return items;
    });
  }

  Future<void> saveEntry(TrackingEntry entry) async {
    final docId = entry.id.isEmpty ? _collection.doc().id : entry.id;
    await _collection.doc(docId).set(entry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _collection.doc(id).delete();
  }

  TrackingSummary computeSummary(
    TrackingKind kind,
    List<TrackingEntry> entries,
  ) {
    if (entries.isEmpty) {
      return const TrackingSummary(
        title: 'Aucune donnee',
        value: '--',
        secondary: 'Ajoute ton premier enregistrement',
        tertiary: '',
      );
    }

    switch (kind) {
      case TrackingKind.layer:
        return _layerSummary(entries);
      case TrackingKind.broiler:
        return _broilerSummary(entries);
    }
  }

  TrackingSummary _layerSummary(List<TrackingEntry> entries) {
    final totalEggs = entries.fold<int>(0, (acc, e) => acc + (e.eggs ?? 0));
    final totalBroken = entries.fold<int>(
      0,
      (acc, e) => acc + (e.brokenEggs ?? 0),
    );
    final last = entries.first;
    final currentEggs = last.eggs ?? 0;
    final marketable = totalEggs - totalBroken;

    return TrackingSummary(
      title: 'Production oeufs (jour)',
      value: '$currentEggs oeufs',
      secondary: 'Total lot: $totalEggs | Commercialisables: $marketable',
      tertiary: 'Casse cumulee: $totalBroken oeufs',
    );
  }

  TrackingSummary _broilerSummary(List<TrackingEntry> entries) {
    final latest = entries.first;
    final oldest = entries.last;

    final latestWeight = latest.avgWeightKg ?? 0;
    final oldestWeight = oldest.avgWeightKg ?? 0;
    final daySpan = entries.length > 1 ? entries.length - 1 : 1;
    final dailyGain = ((latestWeight - oldestWeight) / daySpan).clamp(
      -999,
      999,
    );

    final totalMortality = entries.fold<int>(0, (acc, e) => acc + e.mortality);

    return TrackingSummary(
      title: 'Croissance (poids moyen)',
      value: '${latestWeight.toStringAsFixed(2)} kg',
      secondary: 'Gain moyen: ${dailyGain.toStringAsFixed(3)} kg/j',
      tertiary: 'Mortalite cumulee: $totalMortality sujets',
    );
  }
}
