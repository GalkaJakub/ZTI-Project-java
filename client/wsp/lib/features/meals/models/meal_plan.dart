import 'package:wsp/features/meals/models/planned_meal.dart';

class MealPlan {
  const MealPlan({
    required this.id,
    required this.groupId,
    required this.weekStartDate,
    required this.meals,
  });

  final int id;
  final int groupId;
  final DateTime weekStartDate;
  final List<PlannedMeal> meals;

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final mealsJson = json['meals'] as List<dynamic>? ?? [];

    return MealPlan(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      meals: mealsJson
          .map((item) => PlannedMeal.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
