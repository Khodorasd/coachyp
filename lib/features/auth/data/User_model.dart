class UserModel {
  final String uid;
  final String username;
  final String email;
  final String password;
  final String? profileImgUrl;
  final String? bio;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.password,
    this.profileImgUrl,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "username": username,
      "email": email,
      "password": password,
      "profileImgUrl": profileImgUrl,
      "bio": bio,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      username: json["username"],
      email: json["email"],
      password: json["password"],
      profileImgUrl: json["profileImgUrl"],
      bio: json["bio"],
    );
  }
}
