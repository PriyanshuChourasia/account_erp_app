/// Plain data class for an authenticated user. No behavior.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.contactNo,
  });

  final String id;
  final String name;
  final String email;
  final String username;
  final int contactNo;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: '${json['id'] ?? ''}',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    username: json['username'] as String? ?? '',
    contactNo: json['contactNo'] is int
        ? json['contactNo'] as int
        : int.tryParse('${json['contactNo'] ?? ''}') ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'username': username,
    'contactNo': contactNo,
  };
}
