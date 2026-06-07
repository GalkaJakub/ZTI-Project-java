import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/recipes/models/recipe.dart';
import 'package:wsp/features/recipes/models/recipe_ingredient.dart';

class RecipeService {
  RecipeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Recipe>> getRecipes(int groupId) async {
    final response = await _apiClient.getJsonList(
      '/api/groups/$groupId/recipes',
      authenticated: true,
    );

    return response
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
    final response = await _apiClient.postJsonObject(
      '/api/groups/$groupId/recipes',
      authenticated: true,
      body: _body(
        title: title,
        description: description,
        instructions: instructions,
        ingredients: ingredients,
      ),
    );

    return Recipe.fromJson(response);
  }

  Future<Recipe> updateRecipe({
    required int groupId,
    required int recipeId,
    required String title,
    required String description,
    required String instructions,
    required List<RecipeIngredient> ingredients,
  }) async {
    final response = await _apiClient.putJsonObject(
      '/api/groups/$groupId/recipes/$recipeId',
      authenticated: true,
      body: _body(
        title: title,
        description: description,
        instructions: instructions,
        ingredients: ingredients,
      ),
    );

    return Recipe.fromJson(response);
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
