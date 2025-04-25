class UserEntity {
  final String email;
  final String username;
  final String role;
  final String status;
  final String? password; // Only used during registration
  final String? profileImgUrl; // Optional for profile picture

  UserEntity({
    required this.email,
    required this.username,
    required this.role,
    required this.status,
    this.password,
    this.profileImgUrl,
  });

  // Convert to Firestore-friendly format
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'role': role,
      'status': status,
      'profileImgUrl': profileImgUrl,
      // Note: 'password' is excluded to avoid storing it
    };
  }

  // Create entity from Firestore data
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      email: json['email'],
      username: json['username'],
      role: json['role'],
      status: json['status'],
      profileImgUrl: json['profileImgUrl'],
    );
  }
}
