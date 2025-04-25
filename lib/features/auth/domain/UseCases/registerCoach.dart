import 'dart:io';
import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';
import 'package:coachyp/features/auth/domain/Repo/auth_repository.dart';



class RegisterCoach {
  final AuthRepository repository;

  RegisterCoach(this.repository);

  Future<void> call(UserEntity coach, File documentFile) async {
    await repository.registerCoachWithDocument(coach, documentFile);
  }
}
