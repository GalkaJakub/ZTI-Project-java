import 'package:wsp/core/auth/auth_token_storage.dart';
import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/auth/models/auth_response.dart';

class AuthService {
  AuthService({ApiClient? apiClient, AuthTokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJsonObject(
        '/api/auth/login',
        body: {'email': email.trim(), 'password': password},
      );

      return _saveSession(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw const AuthException('Nieprawidłowy email lub hasło.');
      }

      throw AuthException(e.message);
    }
  }

  Future<AuthResponse> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.postJsonObject(
        '/api/auth/register',
        body: {
          'email': email.trim(),
          'password': password,
          'displayName': displayName.trim(),
        },
      );

      return _saveSession(response);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> signOut() {
    return _tokenStorage.clear();
  }

  Future<AuthResponse> _saveSession(Map<String, dynamic> responseBody) async {
    try {
      final response = AuthResponse.fromJson(responseBody);

      await _tokenStorage.saveAccessToken(response.accessToken);
      return response;
    } on TypeError {
      throw const AuthException('Serwer zwrócił niepoprawną odpowiedź.');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
