import 'package:flutter/material.dart';
import 'package:wsp/features/meals/models/planned_meal.dart';
import 'package:wsp/features/meals/utils/meal_date_utils.dart';

class DayPlanCard extends StatelessWidget {
  const DayPlanCard({
    super.key,
    required this.date,
    required this.meals,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime date;
  final List<PlannedMeal> meals;
  final VoidCallback onAdd;
  final ValueChanged<PlannedMeal> onEdit;
  final ValueChanged<PlannedMeal> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${weekdayLabel(date)} · ${formatShortDate(date)}',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Dodaj posiłek',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            if (meals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 6),
                child: Text('Brak zaplanowanych posiłków.'),
              )
            else
              for (final meal in meals)
                _MealTile(
                  meal: meal,
                  onEdit: () => onEdit(meal),
                  onDelete: () => onDelete(meal),
                ),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
  });

  final PlannedMeal meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFEFF6FF),
        child: Icon(Icons.restaurant, color: Color(0xFF2563EB)),
      ),
      title: Text(
        meal.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          meal.mealType.label,
          if ((meal.recipeTitle ?? '').isNotEmpty) meal.recipeTitle!,
          if ((meal.notes ?? '').isNotEmpty) meal.notes!,
        ].join(' · '),
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Edytuj',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Usuń',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }
}
