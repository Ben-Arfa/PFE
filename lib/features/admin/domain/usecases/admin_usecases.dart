import 'package:kiwo/features/admin/domain/entities/admin_user.dart';
import 'package:kiwo/features/admin/domain/repositories/admin_repository.dart';

class AdminUseCases {
  final AdminRepository _repository;

  const AdminUseCases(this._repository);

  Stream<int> watchTotalUsers() => _repository.watchTotalUsers();

  Stream<int> watchAdminUsers() => _repository.watchAdminUsers();

  Stream<List<AdminUser>> watchRecentUsers({int limit = 8}) {
    return _repository.watchRecentUsers(limit: limit);
  }

  Future<void> createUserAccount({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return _repository.createUserAccount(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }

  Future<void> updateUserRole({required String userId, required String role}) {
    return _repository.updateUserRole(userId: userId, role: role);
  }

  Future<void> sendPasswordReset(String email) {
    return _repository.sendPasswordReset(email);
  }

  Future<void> deleteUserAccount({required String userId}) {
    return _repository.deleteUserAccount(userId: userId);
  }
}
