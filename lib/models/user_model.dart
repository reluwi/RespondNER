
enum UserRole { responder, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isResponder => role == UserRole.responder;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.toString(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: UserRole.values.firstWhere(
      (role) => role.toString() == json['role'],
      orElse: () => UserRole.responder,
    ),
  );
}