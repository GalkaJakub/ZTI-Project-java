import 'package:wsp/features/meals/models/meal_type.dart';

class MealDraft {
  const MealDraft({
    required this.mealDate,
    required this.mealType,
    required this.title,
    required this.notes,
    required this.recipeId,
  });

  final DateTime mealDate;
  final MealType mealType;
  final String title;
  final String notes;
  final int? recipeId;
}
