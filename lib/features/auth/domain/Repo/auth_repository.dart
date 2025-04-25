import 'dart:io';

import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';

abstract class AuthRepository {
  Future<void> registerUser(UserEntity user, String password);
  Future<UserEntity> loginUser(String email, String password);
  Future<void> registerCoachWithDocument(UserEntity user, File documentFile);

}