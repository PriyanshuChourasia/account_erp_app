import '../../../config/api_config.dart';
import '../../../network/api_service.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

/// Raw HTTP calls for auth. No parsing, no state.
class AuthService {
  AuthService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> login(LoginRequestModel request) =>
      _apiService.post(ApiConfig.loginEndpoint, data: request.toJson());

  Future<Map<String, dynamic>> register(RegisterRequestModel request) =>
      _apiService.post(ApiConfig.registerEndpoint, data: request.toJson());

  Future<Map<String, dynamic>> logout() =>
      _apiService.post(ApiConfig.logoutEndpoint);

  Future<Map<String, dynamic>> fetchProfile() =>
      _apiService.post(ApiConfig.profileEndpoint);
}
