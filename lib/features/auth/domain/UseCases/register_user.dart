import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/domain/Repo/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<void> call(UserEntity user, String password) {
    return repository.registerUser(user, password);
  }
}