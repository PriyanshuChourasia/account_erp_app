/// Request payload for the register endpoint.
///
/// Mirrors the backend `UserRegisterDTO` record. [altContactNo] is omitted
/// from JSON when null.
class RegisterRequestModel {
  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.countryCode,
    required this.contactNo,
    this.altContactNo,
  });

  final String name;
  final String email;
  final String password;

  /// Dialling code, at most 3 characters (e.g. `+91`).
  final String countryCode;
  final int contactNo;
  final int? altContactNo;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'countryCode': countryCode,
    'contactNo': contactNo,
    if (altContactNo != null) 'altContactNo': altContactNo,
  };
}
