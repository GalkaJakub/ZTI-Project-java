import 'package:flutter/material.dart';
import 'package:wsp/features/meals/models/meal_draft.dart';
import 'package:wsp/features/meals/models/meal_type.dart';
import 'package:wsp/features/meals/models/planned_meal.dart';
import 'package:wsp/features/meals/utils/meal_date_utils.dart';
import 'package:wsp/features/recipes/models/recipe.dart';

class MealDialog extends StatefulWidget {
  const MealDialog({
    super.key,
    required this.weekStartDate,
    required this.recipes,
    this.meal,
    this.initialDate,
  });

  final DateTime weekStartDate;
  final List<Recipe> recipes;
  final PlannedMeal? meal;
  final DateTime? initialDate;

  @override
  State<MealDialog> createState() => _MealDialogState();
}

class _MealDialogState extends State<MealDialog> {
  late DateTime _mealDate;
  late MealType _mealType;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  int? _recipeId;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _mealDate = meal?.mealDate ?? widget.initialDate ?? widget.weekStartDate;
    _mealType = meal?.mealType ?? MealType.dinner;
    _titleController = TextEditingController(text: meal?.title ?? '');
    _notesController = TextEditingController(text: meal?.notes ?? '');
    _recipeId = meal?.recipeId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectRecipe(int? recipeId) {
    setState(() {
      _recipeId = recipeId;
      if (recipeId != null && _titleController.text.trim().isEmpty) {
        final recipe = widget.recipes.firstWhere(
          (recipe) => recipe.id == recipeId,
        );
        _titleController.text = recipe.title;
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    Navigator.pop(
      context,
      MealDraft(
        mealDate: _mealDate,
        mealType: _mealType,
        title: title,
        notes: _notesController.text.trim(),
        recipeId: _recipeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = weekDays(widget.weekStartDate);

    return AlertDialog(
      title: Text(widget.meal == null ? 'Nowy posiłek' : 'Edytuj posiłek'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<DateTime>(
              initialValue: _mealDate,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.event_outlined),
                labelText: 'Dzień',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final day in days)
                  DropdownMenuItem(
                    value: day,
                    child: Text(
                      '${weekdayLabel(day)} · ${formatShortDate(day)}',
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _mealDate = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MealType>(
              initialValue: _mealType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.restaurant_outlined),
                labelText: 'Typ posiłku',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final type in MealType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _mealType = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _recipeId,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.menu_book_outlined),
                labelText: 'Przepis',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Bez przepisu'),
                ),
                for (final recipe in widget.recipes)
                  DropdownMenuItem<int?>(
                    value: recipe.id,
                    child: Text(recipe.title),
                  ),
              ],
              onChanged: _selectRecipe,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.drive_file_rename_outline),
                labelText: 'Tytuł',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.notes_outlined),
                labelText: 'Notatka',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Zapisz')),
      ],
    );
  }
}
