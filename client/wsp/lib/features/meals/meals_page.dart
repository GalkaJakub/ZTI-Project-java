import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_storage.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/meals/models/meal_plan.dart';
import 'package:wsp/features/meals/models/meal_type.dart';
import 'package:wsp/features/meals/models/planned_meal.dart';
import 'package:wsp/features/meals/services/meal_plan_service.dart';
import 'package:wsp/features/recipes/models/recipe.dart';
import 'package:wsp/features/recipes/services/recipe_service.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final _groupService = GroupService();
  final _mealPlanService = MealPlanService();
  final _recipeService = RecipeService();
  final _activeGroupStorage = ActiveGroupStorage();

  late Future<_MealsPageData> _pageFuture;
  int? _selectedGroupId;
  DateTime _weekStartDate = _startOfWeek(DateTime.now());

  @override
  void initState() {
    super.initState();
    _pageFuture = _loadPage();
  }

  Future<void> _refresh() {
    final pageFuture = _loadPage();

    setState(() {
      _pageFuture = pageFuture;
    });

    return pageFuture.then((_) {});
  }

  Future<_MealsPageData> _loadPage() async {
    final groups = await _groupService.getGroups();
    final savedGroupId = await _activeGroupStorage.readActiveGroupId();

    if (groups.isEmpty) {
      _selectedGroupId = null;
      return const _MealsPageData(
        groups: [],
        selectedGroup: null,
        mealPlan: null,
        recipes: [],
      );
    }

    final selectedGroup = _selectExistingGroup(
      groups: groups,
      preferredId: _selectedGroupId ?? savedGroupId,
    );

    _selectedGroupId = selectedGroup.id;
    await _activeGroupStorage.saveActiveGroupId(selectedGroup.id);

    final results = await Future.wait([
      _mealPlanService.getWeekPlan(
        groupId: selectedGroup.id,
        dateInWeek: _weekStartDate,
      ),
      _recipeService.getRecipes(selectedGroup.id),
    ]);

    return _MealsPageData(
      groups: groups,
      selectedGroup: selectedGroup,
      mealPlan: results[0] as MealPlan,
      recipes: results[1] as List<Recipe>,
    );
  }

  UserGroup _selectExistingGroup({
    required List<UserGroup> groups,
    required int? preferredId,
  }) {
    for (final group in groups) {
      if (group.id == preferredId) {
        return group;
      }
    }

    return groups.first;
  }

  Future<void> _changeGroup(int groupId) async {
    setState(() {
      _selectedGroupId = groupId;
      _pageFuture = _loadPage();
    });
    await _activeGroupStorage.saveActiveGroupId(groupId);
  }

  void _changeWeek(int offset) {
    setState(() {
      _weekStartDate = _weekStartDate.add(Duration(days: offset * 7));
      _pageFuture = _loadPage();
    });
  }

  void _goToCurrentWeek() {
    setState(() {
      _weekStartDate = _startOfWeek(DateTime.now());
      _pageFuture = _loadPage();
    });
  }

  Future<void> _createMeal(_MealsPageData data, {DateTime? initialDate}) async {
    final groupId = _selectedGroupId;
    if (groupId == null) {
      return;
    }

    final draft = await _showMealDialog(
      recipes: data.recipes,
      initialDate: initialDate ?? _weekStartDate,
    );
    if (draft == null) {
      return;
    }

    try {
      await _mealPlanService.createMeal(
        groupId: groupId,
        dateInWeek: _weekStartDate,
        mealDate: draft.mealDate,
        mealType: draft.mealType,
        title: draft.title,
        notes: draft.notes,
        recipeId: draft.recipeId,
      );
      if (!mounted) return;
      await _refresh();
      _showMessage('Dodano posiłek.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się dodać posiłku: $e');
    }
  }

  Future<void> _editMeal(_MealsPageData data, PlannedMeal meal) async {
    final draft = await _showMealDialog(recipes: data.recipes, meal: meal);
    if (draft == null) {
      return;
    }

    try {
      await _mealPlanService.updateMeal(
        groupId: data.selectedGroup!.id,
        dateInWeek: _weekStartDate,
        mealId: meal.id,
        mealDate: draft.mealDate,
        mealType: draft.mealType,
        title: draft.title,
        notes: draft.notes,
        recipeId: draft.recipeId,
      );
      if (!mounted) return;
      await _refresh();
      _showMessage('Zapisano posiłek.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się zapisać posiłku: $e');
    }
  }

  Future<void> _deleteMeal(_MealsPageData data, PlannedMeal meal) async {
    try {
      await _mealPlanService.deleteMeal(
        groupId: data.selectedGroup!.id,
        dateInWeek: _weekStartDate,
        mealId: meal.id,
      );
      if (!mounted) return;
      await _refresh();
      _showMessage('Usunięto posiłek.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się usunąć posiłku: $e');
    }
  }

  Future<_MealDraft?> _showMealDialog({
    required List<Recipe> recipes,
    PlannedMeal? meal,
    DateTime? initialDate,
  }) {
    return showDialog<_MealDraft>(
      context: context,
      builder: (context) {
        return _MealDialog(
          weekStartDate: _weekStartDate,
          recipes: recipes,
          meal: meal,
          initialDate: initialDate,
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      floatingActionButton: FutureBuilder<_MealsPageData>(
        future: _pageFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return FloatingActionButton.extended(
            onPressed: data?.selectedGroup == null
                ? null
                : () => _createMeal(data!),
            icon: const Icon(Icons.add),
            label: const Text('Posiłek'),
          );
        },
      ),
      body: SafeArea(
        child: FutureBuilder<_MealsPageData>(
          future: _pageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _MealsError(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final data = snapshot.requireData;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _MealsHeader(
                    groups: data.groups,
                    selectedGroup: data.selectedGroup,
                    weekStartDate: _weekStartDate,
                    onGroupChanged: _changeGroup,
                    onPreviousWeek: () => _changeWeek(-1),
                    onNextWeek: () => _changeWeek(1),
                    onCurrentWeek: _goToCurrentWeek,
                  ),
                  const SizedBox(height: 18),
                  if (data.groups.isEmpty)
                    const _NoGroupCard()
                  else
                    for (final day in _weekDays(_weekStartDate))
                      _DayPlanCard(
                        date: day,
                        meals: _mealsForDay(data.mealPlan?.meals ?? [], day),
                        onAdd: () => _createMeal(data, initialDate: day),
                        onEdit: (meal) => _editMeal(data, meal),
                        onDelete: (meal) => _deleteMeal(data, meal),
                      ),
                  const SizedBox(height: 88),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<PlannedMeal> _mealsForDay(List<PlannedMeal> meals, DateTime day) {
    final normalizedDay = _dateOnly(day);
    return meals
        .where((meal) => _sameDay(meal.mealDate, normalizedDay))
        .toList()
      ..sort((a, b) => a.mealType.index.compareTo(b.mealType.index));
  }

  static DateTime _startOfWeek(DateTime date) {
    final dateOnly = _dateOnly(date);
    return dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _sameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static List<DateTime> _weekDays(DateTime weekStartDate) {
    return List.generate(
      7,
      (index) => weekStartDate.add(Duration(days: index)),
    );
  }
}

class _MealsPageData {
  const _MealsPageData({
    required this.groups,
    required this.selectedGroup,
    required this.mealPlan,
    required this.recipes,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final MealPlan? mealPlan;
  final List<Recipe> recipes;
}

class _MealDraft {
  const _MealDraft({
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

class _MealsHeader extends StatelessWidget {
  const _MealsHeader({
    required this.groups,
    required this.selectedGroup,
    required this.weekStartDate,
    required this.onGroupChanged,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final DateTime weekStartDate;
  final ValueChanged<int> onGroupChanged;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final weekEndDate = weekStartDate.add(const Duration(days: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Plan tygodnia',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (groups.isNotEmpty) ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: selectedGroup?.id,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.groups_outlined),
              labelText: 'Grupa',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              for (final group in groups)
                DropdownMenuItem(value: group.id, child: Text(group.name)),
            ],
            onChanged: (value) {
              if (value != null) {
                onGroupChanged(value);
              }
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Poprzedni tydzień',
                  onPressed: onPreviousWeek,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_formatDate(weekStartDate)} - ${_formatDate(weekEndDate)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: onCurrentWeek,
                        child: const Text('Bieżący tydzień'),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Następny tydzień',
                  onPressed: onNextWeek,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DayPlanCard extends StatelessWidget {
  const _DayPlanCard({
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
                    '${_weekdayLabel(date)} · ${_formatDate(date)}',
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

class _MealDialog extends StatefulWidget {
  const _MealDialog({
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
  State<_MealDialog> createState() => _MealDialogState();
}

class _MealDialogState extends State<_MealDialog> {
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
      _MealDraft(
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
    final weekDays = List.generate(
      7,
      (index) => widget.weekStartDate.add(Duration(days: index)),
    );

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
                for (final day in weekDays)
                  DropdownMenuItem(
                    value: day,
                    child: Text('${_weekdayLabel(day)} · ${_formatDate(day)}'),
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

class _NoGroupCard extends StatelessWidget {
  const _NoGroupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.groups_outlined, color: Color(0xFF2563EB)),
          SizedBox(width: 12),
          Expanded(child: Text('Najpierw utwórz albo wybierz grupę.')),
        ],
      ),
    );
  }
}

class _MealsError extends StatelessWidget {
  const _MealsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month';
}

String _weekdayLabel(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'Poniedziałek',
    DateTime.tuesday => 'Wtorek',
    DateTime.wednesday => 'Środa',
    DateTime.thursday => 'Czwartek',
    DateTime.friday => 'Piątek',
    DateTime.saturday => 'Sobota',
    DateTime.sunday => 'Niedziela',
    _ => '',
  };
}
