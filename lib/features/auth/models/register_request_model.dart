/// Request payload for the registration endpoint.
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
  });

  final String name;
  final String email;
  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'username': username,
    'password': password,
  };
}
