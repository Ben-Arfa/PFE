import 'package:kiwo/features/admin/data/services/admin_service.dart';
import 'package:kiwo/features/admin/domain/entities/admin_user.dart';
import 'package:kiwo/features/admin/domain/repositories/admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  final AdminService _adminService;

  FirebaseAdminRepository(this._adminService);

  @override
  Stream<int> watchTotalUsers() => _adminService.watchTotalUsers();

  @override
  Stream<int> watchAdminUsers() => _adminService.watchAdminUsers();

  @override
  Stream<List<AdminUser>> watchRecentUsers({int limit = 8}) {
    return _adminService
        .watchRecentUsers(limit: limit)
        .map((items) => items.map(AdminUser.fromMap).toList());
  }

  @override
  Future<void> createUserAccount({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return _adminService.createUserAccount(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }

  @override
  Future<void> updateUserRole({required String userId, required String role}) {
    return _adminService.updateUserRole(userId: userId, role: role);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _adminService.sendPasswordReset(email);
  }

  @override
  Future<void> deleteUserAccount({required String userId}) {
    return _adminService.deleteUserAccount(userId: userId);
  }
}
