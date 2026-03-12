import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_exception.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Stream utilisateur ───────────────────────────────────────────
  Stream<User?> get userStream => _auth.authStateChanges();

  // ── Connexion ────────────────────────────────────────────────────
  Future<void> signIn({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }

    // Vérification des noms en Firestore
    final uid = credential.user!.uid;
    final snap = await _firestore.collection('users').doc(uid).get();

    if (snap.exists) {
      final data = snap.data()!;
      final storedFirst = (data['firstName'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final storedLast = (data['lastName'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final enteredFirst = firstName.trim().toLowerCase();
      final enteredLast = lastName.trim().toLowerCase();

      if (storedLast.isNotEmpty && storedLast != enteredLast) {
        await _auth.signOut();
        throw AuthException(
          'Le nom ne correspond pas à celui enregistré.',
          field: 'name',
        );
      }
      if (storedFirst.isNotEmpty && storedFirst != enteredFirst) {
        await _auth.signOut();
        throw AuthException(
          'Le prénom ne correspond pas à celui enregistré.',
          field: 'name',
        );
      }
    }
  }

  // ── Inscription ──────────────────────────────────────────────────
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Déconnexion ──────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Données utilisateur ──────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.data();
  }

  // ── Réinitialisation mot de passe ───────────────────────────────
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Modifier nom / prénom ────────────────────────────────────────
  Future<void> updateUserData({
    required String firstName,
    required String lastName,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AuthException('Utilisateur non connecté.');
    await _firestore.collection('users').doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  // ── Modifier email ───────────────────────────────────────────────
  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Utilisateur non connecté.');

    // Ré-authentification requise par Firebase avant changement email
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(newEmail);

      // Met à jour aussi dans Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Modifier mot de passe ────────────────────────────────────────
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AuthException('Utilisateur non connecté.');

    try {
      // Ré-authentification requise par Firebase
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // ── Mapping erreurs Firebase ─────────────────────────────────────
  AuthException _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-email':
      case 'invalid-credential':
        return AuthException(
          'Aucun compte trouvé pour cet email.',
          field: 'email',
        );
      case 'email-already-in-use':
        return AuthException('Cet email est déjà utilisé.', field: 'email');
      case 'wrong-password':
      case 'invalid-password':
        return AuthException('Mot de passe incorrect.', field: 'password');
      case 'weak-password':
        return AuthException(
          'Mot de passe trop faible. Minimum 6 caractères.',
          field: 'password',
        );
      case 'requires-recent-login':
        return AuthException('Session expirée. Reconnecte-toi et réessaie.');
      case 'user-disabled':
        return AuthException('Ce compte a été désactivé.');
      case 'too-many-requests':
        return AuthException(
          'Trop de tentatives. Réessaie dans quelques minutes.',
        );
      case 'network-request-failed':
        return AuthException('Pas de connexion réseau.');
      default:
        return AuthException('Erreur inattendue : ${e.message ?? e.code}');
    }
  }
}
