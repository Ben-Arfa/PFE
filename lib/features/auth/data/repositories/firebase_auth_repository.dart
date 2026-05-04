import 'package:kiwo/features/auth/data/services/auth_service.dart';
import 'package:kiwo/features/auth/domain/entities/user_profile.dart';
import 'package:kiwo/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final AuthService _authService;

  FirebaseAuthRepository(this._authService);

  @override
  String? currentUserId() => _authService.currentUserId;

  @override
  Stream<bool> watchAuthentication() {
    return _authService.userStream.map((user) => user != null);
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final userData = await _authService.getUserData();
    if (userData == null) return null;
    return UserProfile.fromMap(userData);
  }

  @override
  Stream<UserProfile?> watchCurrentUserProfile() {
    return _authService.watchCurrentUserData().map((data) {
      if (data == null) return null;
      return UserProfile.fromMap(data);
    });
  }

  @override
  String resolveRole(UserProfile? profile) {
    return profile?.role == 'admin' ? 'admin' : 'user';
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _authService.sendPasswordReset(email: email);
  }

  @override
  Future<void> updateUserData({
    required String firstName,
    required String lastName,
  }) {
    return _authService.updateUserData(
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
