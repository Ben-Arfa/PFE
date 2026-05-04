import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfigService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _configDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('config')
        .doc('farm');
  }

  Future<void> saveConfig(Map<String, dynamic> config) async {
    final doc = _configDoc;
    if (doc == null) return;
    try {
      await doc.set(config, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadConfig() async {
    final doc = _configDoc;
    if (doc == null) return null;
    try {
      final snap = await doc.get();
      if (!snap.exists) return null;
      return snap.data();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return null;
      rethrow;
    }
  }

  Future<void> clearConfig() async {
    final doc = _configDoc;
    if (doc == null) return;
    try {
      await doc.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
  }
}
