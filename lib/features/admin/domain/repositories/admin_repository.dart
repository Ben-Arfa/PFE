import 'package:kiwo/features/admin/domain/entities/admin_user.dart';

abstract class AdminRepository {
  Stream<int> watchTotalUsers();

  Stream<int> watchAdminUsers();

  Stream<List<AdminUser>> watchRecentUsers({int limit = 8});

  Future<void> createUserAccount({
    required String firstName,
    required String lastName,
    required String email,
  });

  Future<void> updateUserRole({required String userId, required String role});

  Future<void> sendPasswordReset(String email);

  Future<void> deleteUserAccount({required String userId});
}
