import 'package:kiwo/features/auth/domain/entities/user_profile.dart';
import 'package:kiwo/features/auth/domain/repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository _repository;

  const AuthUseCases(this._repository);

  String? currentUserId() => _repository.currentUserId();

  Stream<bool> watchAuthentication() => _repository.watchAuthentication();

  Future<void> signIn({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }

  Future<void> signOut() => _repository.signOut();

  Future<UserProfile?> getCurrentUserProfile() {
    return _repository.getCurrentUserProfile();
  }

  Stream<UserProfile?> watchCurrentUserProfile() {
    return _repository.watchCurrentUserProfile();
  }

  String resolveRole(UserProfile? profile) => _repository.resolveRole(profile);

  Future<void> sendPasswordReset({required String email}) {
    return _repository.sendPasswordReset(email: email);
  }

  Future<void> updateUserData({
    required String firstName,
    required String lastName,
  }) {
    return _repository.updateUserData(firstName: firstName, lastName: lastName);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
