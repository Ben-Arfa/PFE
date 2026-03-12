import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service qui persiste la configuration de l'élevage dans Firestore.
/// Chaque utilisateur a son propre document : users/{uid}/config/farm
class ConfigService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference? get _configDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('config')
        .doc('farm');
  }

  // ── Sauvegarde ────────────────────────────────────────────────
  Future<void> saveConfig(Map<String, dynamic> config) async {
    final doc = _configDoc;
    if (doc == null) return;
    await doc.set(config, SetOptions(merge: true));
  }

  // ── Lecture ───────────────────────────────────────────────────
  Future<Map<String, dynamic>?> loadConfig() async {
    final doc = _configDoc;
    if (doc == null) return null;
    final snap = await doc.get();
    if (!snap.exists) return null;
    return snap.data() as Map<String, dynamic>?;
  }

  // ── Suppression (reset) ───────────────────────────────────────
  Future<void> clearConfig() async {
    final doc = _configDoc;
    if (doc == null) return;
    await doc.delete();
  }
}
