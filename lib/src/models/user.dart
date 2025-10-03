class User {
  final String id;
  final String email;
  final String role;  // 'user', 'owner', 'admin'
  final bool isApproved;
  final bool isVerified;
  final String? fcmToken;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.isApproved = false,
    this.isVerified = false,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'],
    email: json['email'],
    role: json['role'],
    isApproved: json['isApproved'] ?? false,
    isVerified: json['isVerified'] ?? false,
    fcmToken: json['fcmToken'],
  );
}