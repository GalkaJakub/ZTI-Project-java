import 'package:wsp/features/recipes/models/recipe_ingredient.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    required this.instructions,
    required this.ingredients,
  });

  final int id;
  final int groupId;
  final String title;
  final String? description;
  final String instructions;
  final List<RecipeIngredient> ingredients;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];

    return Recipe(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      instructions: json['instructions'] as String,
      ingredients: ingredientsJson
          .map(
            (item) => RecipeIngredient.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
