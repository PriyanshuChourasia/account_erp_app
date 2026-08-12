import 'user_model.dart';

/// Successful login result: a token plus the authenticated user.
class LoginResponseModel {
  const LoginResponseModel({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        token: json['token'] as String? ?? '',
        user: UserModel.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
