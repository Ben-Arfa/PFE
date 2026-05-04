import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'users';

  /// Watch current user profile stream
  Stream<UserProfile?> watchCurrentUserProfile() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return null;
      return UserProfile.fromMap(snapshot.id, snapshot.data() ?? {});
    });
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final snapshot = await _firestore.collection(_collection).doc(userId).get();
    if (!snapshot.exists) return null;

    return UserProfile.fromMap(snapshot.id, snapshot.data() ?? {});
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(_collection).doc(userId).update({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update specific profile field
  Future<void> updateProfileField(String field, dynamic value) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(_collection).doc(userId).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Re-authenticate user with old password
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: oldPassword),
      );

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Change email
  Future<void> changeEmail(String password, String newEmail) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Re-authenticate user with password
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );

      // Update email with verification
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw Exception('Failed to change email: $e');
    }
  }

  /// Delete profile / logout
  Future<void> deleteProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Delete user data from Firestore
    await _firestore.collection(_collection).doc(userId).delete();

    // Delete Firebase Auth user
    await _auth.currentUser?.delete();
    await _auth.signOut();
  }
}
