import 'dart:convert';

import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/shopping/models/shopping_item.dart';

class ShoppingService {
  ShoppingService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ShoppingItem>> getItems(int groupId) async {
    final response = await _apiClient.getJson(
      '/api/groups/$groupId/shopping-items',
      authenticated: true,
    );

    final decoded = jsonDecode(response) as List<dynamic>;
    return decoded
        .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ShoppingItem> createItem({
    required int groupId,
    required String name,
    required String quantity,
  }) async {
    final response = await _apiClient.postJson(
      '/api/groups/$groupId/shopping-items',
      authenticated: true,
      body: {'name': name.trim(), 'quantity': quantity.trim()},
    );

    return ShoppingItem.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<ShoppingItem> toggleItem({
    required int groupId,
    required int itemId,
  }) async {
    final response = await _apiClient.patchJson(
      '/api/groups/$groupId/shopping-items/$itemId/toggle',
      authenticated: true,
    );

    return ShoppingItem.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<void> deleteItem({required int groupId, required int itemId}) {
    return _apiClient.deleteJson(
      '/api/groups/$groupId/shopping-items/$itemId',
      authenticated: true,
    );
  }
}
