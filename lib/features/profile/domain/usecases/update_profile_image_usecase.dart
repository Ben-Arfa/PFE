import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileImageUseCase {
  final ProfileRepository _repository;

  UpdateProfileImageUseCase(this._repository);

  Future<String?> call(String imagePath) async {
    return _repository.updateProfileImage(imagePath);
  }
}
