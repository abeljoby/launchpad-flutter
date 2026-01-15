// User model
class User {
  final int id;
  final String email;
  final String name;
  final String avatarUrl;
  final String? bio;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role,
    };
  }
}