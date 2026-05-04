import 'package:kiwo/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  String? currentUserId();

  Stream<bool> watchAuthentication();

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<UserProfile?> getCurrentUserProfile();

  Stream<UserProfile?> watchCurrentUserProfile();

  String resolveRole(UserProfile? profile);

  Future<void> sendPasswordReset({required String email});

  Future<void> updateUserData({
    required String firstName,
    required String lastName,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
