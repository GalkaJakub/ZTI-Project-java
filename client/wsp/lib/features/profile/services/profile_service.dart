import 'dart:convert';

import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/profile/models/profile_user.dart';

class ProfileService {
  ProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ProfileUser> getCurrentUser() async {
    final response = await _apiClient.getJson(
      '/api/users/me',
      authenticated: true,
    );

    return ProfileUser.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<ProfileUser> updateDisplayName(String displayName) async {
    final response = await _apiClient.putJson(
      '/api/users/me',
      authenticated: true,
      body: {'displayName': displayName.trim()},
    );

    return ProfileUser.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }
}
