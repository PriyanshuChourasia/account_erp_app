/// Request payload for the registration endpoint.
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.contactNo,
    required this.countryCode,
    this.altContactNo,
    this.dateOfBirth,
  });

  final String name;
  final String email;
  final String password;
  final int contactNo;
  final String countryCode;
  final int? altContactNo;
  final String? dateOfBirth;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'contactNo': contactNo,
    'countryCode': countryCode,
    if (altContactNo != null) 'altContactNo': altContactNo,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
  };
}
