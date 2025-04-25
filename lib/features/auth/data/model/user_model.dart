import 'package:coachyp/features/auth/domain/Enteties/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String email,
    required String username,
    required String password,
    required String role,
    required String status,
  }) : super(
          email: email,
          username: username,
          password: password,
          role: role,
          status: status,
        );

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      username: map['username'],
      password: '', // Password shouldn't be stored in Firestore
      role: map['role'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'role': role,
      'status': status,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
