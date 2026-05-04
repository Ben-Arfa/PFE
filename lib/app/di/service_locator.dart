import 'package:kiwo/features/admin/data/repositories/firebase_admin_repository.dart';
import 'package:kiwo/features/admin/data/services/admin_service.dart';
import 'package:kiwo/features/admin/domain/usecases/admin_usecases.dart';
import 'package:kiwo/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:kiwo/features/auth/data/services/auth_service.dart';
import 'package:kiwo/features/auth/domain/usecases/auth_usecases.dart';

class ServiceLocator {
  ServiceLocator._();
  static final instance = ServiceLocator._();

  late final AuthUseCases authUseCases = AuthUseCases(
    FirebaseAuthRepository(AuthService()),
  );

  late final AdminUseCases adminUseCases = AdminUseCases(
    FirebaseAdminRepository(AdminService()),
  );
}
