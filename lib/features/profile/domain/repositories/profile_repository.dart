import 'package:kiwo/features/profile/domain/entities/user_profile.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Watch current user profile stream
  Stream<UserProfile?> watchCurrentUserProfile();

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile();

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile);

  /// Update specific profile field
  Future<void> updateProfileField(String field, dynamic value);

  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword);

  /// Change email
  Future<void> changeEmail(String password, String newEmail);

  /// Update profile image
  Future<String?> updateProfileImage(String imagePath);

  /// Delete profile (logout)
  Future<void> deleteProfile();
}
