import 'package:wsp/features/recipes/models/recipe_ingredient.dart';

class RecipeDraft {
  const RecipeDraft({
    required this.title,
    required this.description,
    required this.instructions,
    required this.ingredients,
  });

  final String title;
  final String description;
  final String instructions;
  final List<RecipeIngredient> ingredients;
}
