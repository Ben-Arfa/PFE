import 'package:kiwo/features/profile/domain/entities/user_profile.dart';
import 'package:kiwo/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Stream<UserProfile?> call() {
    return _repository.watchCurrentUserProfile();
  }
}
