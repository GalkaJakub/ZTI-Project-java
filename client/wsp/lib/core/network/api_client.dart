import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wsp/core/auth/auth_token_storage.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    AuthTokenStorage? tokenStorage,
    this.baseUrl = 'http://localhost:8080',
  }) : _client = client ?? http.Client(),
       _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final String baseUrl;
  final http.Client _client;
  final AuthTokenStorage _tokenStorage;

  Future<String> getJson(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters: queryParameters),
      headers: await _headers(authenticated: authenticated),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getJsonObject(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _decodeObject(
      await getJson(
        path,
        queryParameters: queryParameters,
        authenticated: authenticated,
      ),
    );
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _decodeList(
      await getJson(
        path,
        queryParameters: queryParameters,
        authenticated: authenticated,
      ),
    );
  }

  Future<String> postJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: await _headers(json: true, authenticated: authenticated),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postJsonObject(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    return _decodeObject(
      await postJson(path, body: body, authenticated: authenticated),
    );
  }

  Future<String> putJson(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    final response = await _client.put(
      _buildUri(path),
      headers: await _headers(json: true, authenticated: authenticated),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> putJsonObject(
    String path, {
    required Map<String, dynamic> body,
    bool authenticated = false,
  }) async {
    return _decodeObject(
      await putJson(path, body: body, authenticated: authenticated),
    );
  }

  Future<String> patchJson(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final response = await _client.patch(
      _buildUri(path),
      headers: await _headers(json: body != null, authenticated: authenticated),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patchJsonObject(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    return _decodeObject(
      await patchJson(path, body: body, authenticated: authenticated),
    );
  }

  Future<String> deleteJson(String path, {bool authenticated = false}) async {
    final response = await _client.delete(
      _buildUri(path),
      headers: await _headers(authenticated: authenticated),
    );

    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers({
    bool json = false,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (json) {
      headers['Content-Type'] = 'application/json';
    }

    if (authenticated) {
      final accessToken = await _tokenStorage.readAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw const ApiException(
          statusCode: 401,
          message: 'Brak aktywnej sesji. Zaloguj się ponownie.',
        );
      }

      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  String _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _errorMessage(response.body),
      );
    }

    return response.body;
  }

  String _errorMessage(String body) {
    if (body.isEmpty) {
      return 'Błąd komunikacji z serwerem.';
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        final message = decoded['message'];
        final error = decoded['error'];

        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        if (message is String && message.isNotEmpty) {
          return message;
        }

        if (error is String && error.isNotEmpty) {
          return error;
        }
      }
    } on FormatException {
      return body;
    }

    return body;
  }

  Map<String, dynamic> _decodeObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      // Fall through to the normalized API error below.
    }

    throw const ApiException(
      statusCode: 0,
      message: 'Serwer zwrócił niepoprawną odpowiedź.',
    );
  }

  List<dynamic> _decodeList(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List<dynamic>) {
        return decoded;
      }
    } on FormatException {
      // Fall through to the normalized API error below.
    }

    throw const ApiException(
      statusCode: 0,
      message: 'Serwer zwrócił niepoprawną odpowiedź.',
    );
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBaseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...queryParameters},
    );
  }
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
