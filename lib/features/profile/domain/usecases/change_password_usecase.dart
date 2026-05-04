import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<void> call(String oldPassword, String newPassword) async {
    return _repository.changePassword(oldPassword, newPassword);
  }
}
