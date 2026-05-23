import 'package:wsp/features/meals/models/meal_type.dart';

class PlannedMeal {
  const PlannedMeal({
    required this.id,
    required this.mealDate,
    required this.mealType,
    required this.title,
    this.notes,
    this.recipeId,
    this.recipeTitle,
  });

  final int id;
  final DateTime mealDate;
  final MealType mealType;
  final String title;
  final String? notes;
  final int? recipeId;
  final String? recipeTitle;

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      id: json['id'] as int,
      mealDate: DateTime.parse(json['mealDate'] as String),
      mealType: MealType.fromApi(json['mealType'] as String),
      title: json['title'] as String,
      notes: json['notes'] as String?,
      recipeId: json['recipeId'] as int?,
      recipeTitle: json['recipeTitle'] as String?,
    );
  }
}
