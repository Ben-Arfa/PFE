import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/poultry_type_input.dart';

class PoultryTypeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('poultryTypes');
  }

  Future<void> createType(PoultryTypeInput input) async {
    final col = _userCollection();
    await col.add({
      ...input.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchAllRaw() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _userCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> updateType(String id, PoultryTypeInput input) async {
    final col = _userCollection();
    await col.doc(id).update({
      ...input.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteType(String id) async {
    final col = _userCollection();
    await col.doc(id).delete();
  }
}
