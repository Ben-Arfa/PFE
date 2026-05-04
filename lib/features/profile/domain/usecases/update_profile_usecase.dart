import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<void> call(UserProfile profile) async {
    return _repository.updateUserProfile(profile);
  }
}
