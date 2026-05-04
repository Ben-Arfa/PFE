import 'package:kiwo/features/profile/data/services/profile_service.dart';
import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  @override
  Stream<UserProfile?> watchCurrentUserProfile() {
    return _profileService.watchCurrentUserProfile();
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() {
    return _profileService.getCurrentUserProfile();
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) {
    return _profileService.updateUserProfile(profile);
  }

  @override
  Future<void> updateProfileField(String field, dynamic value) {
    return _profileService.updateProfileField(field, value);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) {
    return _profileService.changePassword(oldPassword, newPassword);
  }

  @override
  Future<void> changeEmail(String password, String newEmail) {
    return _profileService.changeEmail(password, newEmail);
  }

  @override
  Future<String?> updateProfileImage(String imagePath) async {
    // TODO: Implement image upload to Firebase Storage
    // For now, just return the path
    return imagePath;
  }

  @override
  Future<void> deleteProfile() {
    return _profileService.deleteProfile();
  }
}
