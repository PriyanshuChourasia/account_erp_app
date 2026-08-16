/// Plain data class for an authenticated user. No behavior.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  final String id;
  final String name;
  final String email;
  final String? role;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: '${json['id'] ?? ''}',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (role != null) 'role': role,
  };
}
