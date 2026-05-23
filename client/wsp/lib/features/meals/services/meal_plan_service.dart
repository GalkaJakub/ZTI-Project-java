import 'dart:convert';

import 'package:wsp/core/network/api_client.dart';
import 'package:wsp/features/meals/models/meal_plan.dart';
import 'package:wsp/features/meals/models/meal_type.dart';
import 'package:wsp/features/meals/models/planned_meal.dart';

class MealPlanService {
  MealPlanService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<MealPlan> getWeekPlan({
    required int groupId,
    required DateTime dateInWeek,
  }) async {
    final response = await _apiClient.getJson(
      '/api/groups/$groupId/meal-plans/${_date(dateInWeek)}',
      authenticated: true,
    );

    return MealPlan.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<PlannedMeal> createMeal({
    required int groupId,
    required DateTime dateInWeek,
    required DateTime mealDate,
    required MealType mealType,
    required String title,
    required String notes,
    int? recipeId,
  }) async {
    final response = await _apiClient.postJson(
      '/api/groups/$groupId/meal-plans/${_date(dateInWeek)}/meals',
      authenticated: true,
      body: _body(
        mealDate: mealDate,
        mealType: mealType,
        title: title,
        notes: notes,
        recipeId: recipeId,
      ),
    );

    return PlannedMeal.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<PlannedMeal> updateMeal({
    required int groupId,
    required DateTime dateInWeek,
    required int mealId,
    required DateTime mealDate,
    required MealType mealType,
    required String title,
    required String notes,
    int? recipeId,
  }) async {
    final response = await _apiClient.putJson(
      '/api/groups/$groupId/meal-plans/${_date(dateInWeek)}/meals/$mealId',
      authenticated: true,
      body: _body(
        mealDate: mealDate,
        mealType: mealType,
        title: title,
        notes: notes,
        recipeId: recipeId,
      ),
    );

    return PlannedMeal.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<void> deleteMeal({
    required int groupId,
    required DateTime dateInWeek,
    required int mealId,
  }) {
    return _apiClient.deleteJson(
      '/api/groups/$groupId/meal-plans/${_date(dateInWeek)}/meals/$mealId',
      authenticated: true,
    );
  }

  Map<String, dynamic> _body({
    required DateTime mealDate,
    required MealType mealType,
    required String title,
    required String notes,
    required int? recipeId,
  }) {
    return {
      'mealDate': _date(mealDate),
      'mealType': mealType.apiValue,
      'title': title.trim(),
      'notes': notes.trim(),
      'recipeId': recipeId,
    };
  }

  String _date(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().substring(0, 10);
  }
}
