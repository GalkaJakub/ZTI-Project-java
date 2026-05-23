import 'dart:convert';

import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/groups/models/group_member.dart';
import 'package:wsp/features/groups/models/user_group.dart';

class GroupService {
  GroupService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<UserGroup>> getGroups() async {
    final response = await _apiClient.getJson(
      '/api/groups',
      authenticated: true,
    );

    final decoded = jsonDecode(response) as List<dynamic>;
    return decoded
        .map((item) => UserGroup.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserGroup> createGroup(String name) async {
    final response = await _apiClient.postJson(
      '/api/groups',
      authenticated: true,
      body: {'name': name.trim()},
    );

    return UserGroup.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<UserGroup> joinGroup(String inviteCode) async {
    final response = await _apiClient.postJson(
      '/api/groups/join',
      authenticated: true,
      body: {'inviteCode': inviteCode.trim().toUpperCase()},
    );

    return UserGroup.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<List<GroupMember>> getMembers(int groupId) async {
    final response = await _apiClient.getJson(
      '/api/groups/$groupId/members',
      authenticated: true,
    );

    final decoded = jsonDecode(response) as List<dynamic>;
    return decoded
        .map((item) => GroupMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> leaveGroup(int groupId) {
    return _apiClient.deleteJson(
      '/api/groups/$groupId/members/me',
      authenticated: true,
    );
  }
}
