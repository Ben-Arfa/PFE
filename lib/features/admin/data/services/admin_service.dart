import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kiwo/firebase_options.dart';

class AdminService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<int> watchTotalUsers() {
    return _firestore.collection('users').snapshots().map((snap) => snap.size);
  }

  Stream<int> watchAdminUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<List<Map<String, dynamic>>> watchRecentUsers({int limit = 8}) {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'firstName': (data['firstName'] ?? '').toString(),
              'lastName': (data['lastName'] ?? '').toString(),
              'email': (data['email'] ?? '').toString(),
              'role': (data['role'] ?? 'user').toString(),
            };
          }).toList();
        });
  }

  Future<void> createUserAccount({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) {
      throw Exception('Administrateur non connecté.');
    }

    final adminSnap = await _firestore.collection('users').doc(adminUid).get();
    final isAdmin =
        (adminSnap.data()?['role'] ?? '').toString().toLowerCase() == 'admin';
    if (!isAdmin) {
      throw Exception('Action réservée à un administrateur.');
    }

    final secondaryApp = await _getOrCreateSecondaryApp();
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    UserCredential? credential;
    try {
      final temporaryPassword = _generateTemporaryPassword();
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: temporaryPassword,
      );

      final uid = credential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': adminUid,
      }, SetOptions(merge: true));

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthCreateError(e));
    } finally {
      await secondaryAuth.signOut();
      try {
        await secondaryApp.delete();
      } catch (_) {
        // App can be deleted only when not in use; safe to ignore.
      }
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    if (role != 'user' && role != 'admin') {
      throw Exception('Rôle invalide.');
    }
    await _firestore.collection('users').doc(userId).update({'role': role});
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteUserAccount({required String userId}) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) {
      throw Exception('Administrateur non connecté.');
    }
    if (userId == adminUid) {
      throw Exception('Suppression de votre propre compte interdite.');
    }

    final adminSnap = await _firestore.collection('users').doc(adminUid).get();
    final isAdmin =
        (adminSnap.data()?['role'] ?? '').toString().toLowerCase() == 'admin';
    if (!isAdmin) {
      throw Exception('Action réservée à un administrateur.');
    }

    final userDoc = _firestore.collection('users').doc(userId);

    await _deleteCollectionDocuments(userDoc.collection('tracking'));
    await _deleteCollectionDocuments(userDoc.collection('config'));
    await _deleteLotsWithChildren(userDoc.collection('lots'));
    await _deleteCollectionDocuments(userDoc.collection('poultryTypes'));
    await _deleteCollectionDocuments(userDoc.collection('buildings'));
    await userDoc.delete();
  }

  Future<FirebaseApp> _getOrCreateSecondaryApp() async {
    final appName = 'kiwo_admin_creator';
    for (final app in Firebase.apps) {
      if (app.name == appName) return app;
    }

    return Firebase.initializeApp(
      name: appName,
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> _deleteCollectionDocuments(
    CollectionReference<Map<String, dynamic>> collection, {
    int batchSize = 200,
  }) async {
    while (true) {
      final snap = await collection.limit(batchSize).get();
      if (snap.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snap.docs.length < batchSize) break;
    }
  }

  Future<void> _deleteLotsWithChildren(
    CollectionReference<Map<String, dynamic>> lotsCollection,
  ) async {
    while (true) {
      final snap = await lotsCollection.limit(100).get();
      if (snap.docs.isEmpty) break;

      for (final doc in snap.docs) {
        await _deleteCollectionDocuments(
          doc.reference.collection('dailyEntries'),
        );
        await _deleteCollectionDocuments(
          doc.reference.collection('vaccinationPlans'),
        );
        await _deleteCollectionDocuments(doc.reference.collection('journal'));
      }

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snap.docs.length < 100) break;
    }
  }

  String _generateTemporaryPassword({int length = 20}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%&*';
    final rnd = Random.secure();
    return List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  String _mapAuthCreateError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'operation-not-allowed':
        return 'Création par email/mot de passe non autorisée sur Firebase Auth.';
      default:
        return e.message ?? 'Erreur inconnue lors de la création du compte.';
    }
  }
}
