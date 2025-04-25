import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/domain/Repo/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.loginUser(email, password);
  }
}