import 'dart:convert';

import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/recipes/models/recipe.dart';
import 'package:wsp/features/recipes/models/recipe_ingredient.dart';

class RecipeService {
  RecipeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Recipe>> getRecipes(int groupId) async {
    final response = await _apiClient.getJson(
      '/api/groups/$groupId/recipes',
      authenticated: true,
    );

    final decoded = jsonDecode(response) as List<dynamic>;
    return decoded
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe> createRecipe({
    required int groupId,
    required String title,
    required String description,
    required String instructions,
    required List<RecipeIngredient> ingredients,
  }) async {
    final response = await _apiClient.postJson(
      '/api/groups/$groupId/recipes',
      authenticated: true,
      body: _body(
        title: title,
        description: description,
        instructions: instructions,
        ingredients: ingredients,
      ),
    );

    return Recipe.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<Recipe> updateRecipe({
    required int groupId,
    required int recipeId,
    required String title,
    required String description,
    required String instructions,
    required List<RecipeIngredient> ingredients,
  }) async {
    final response = await _apiClient.putJson(
      '/api/groups/$groupId/recipes/$recipeId',
      authenticated: true,
      body: _body(
        title: title,
        description: description,
        instructions: instructions,
        ingredients: ingredients,
      ),
    );

    return Recipe.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<void> deleteRecipe({required int groupId, required int recipeId}) {
    return _apiClient.deleteJson(
      '/api/groups/$groupId/recipes/$recipeId',
      authenticated: true,
    );
  }

  Map<String, dynamic> _body({
    required String title,
    required String description,
    required String instructions,
    required List<RecipeIngredient> ingredients,
  }) {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'instructions': instructions.trim(),
      'ingredients': ingredients
          .map((ingredient) => ingredient.toJson())
          .toList(),
    };
  }
}
