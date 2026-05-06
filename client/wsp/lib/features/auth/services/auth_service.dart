import 'package:wsp/core/network/api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<String> signIn({
    required String username,
    required String password,
  }) async {
    try {
      return await _apiClient.postJson(
        '/api/auth/login',
        body: {
          'username': username.trim(),
          'password': password,
        },
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw const AuthException('Nieprawidłowy login lub hasło.');
      }

      throw AuthException(e.message);
    }
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      return await _apiClient.postJson(
        '/api/auth/register',
        body: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        },
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
