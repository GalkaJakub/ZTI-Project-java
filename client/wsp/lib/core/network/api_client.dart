import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    http.Client? client,
    this.baseUrl = 'http://10.0.2.2:8080',
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<String> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters: queryParameters),
      headers: const {'Accept': 'application/json'},
    );

    return _handleResponse(response);
  }

  Future<String> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<String> putJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _client.put(
      _buildUri(path),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<String> deleteJson(String path) async {
    final response = await _client.delete(
      _buildUri(path),
      headers: const {'Accept': 'application/json'},
    );

    return _handleResponse(response);
  }

  Map<String, String> get _jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  String _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body.isEmpty
            ? 'Błąd komunikacji z serwerem.'
            : response.body,
      );
    }

    return response.body;
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBaseUrl$normalizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
