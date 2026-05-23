import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/empty_state_card.dart';
import 'package:wsp/core/widgets/page_error_view.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_storage.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/meals/models/meal_draft.dart';
import 'package:wsp/features/meals/models/meal_plan.dart';
import 'package:wsp/features/meals/models/planned_meal.dart';
import 'package:wsp/features/meals/services/meal_plan_service.dart';
import 'package:wsp/features/meals/utils/meal_date_utils.dart';
import 'package:wsp/features/meals/widgets/day_plan_card.dart';
import 'package:wsp/features/meals/widgets/meal_dialog.dart';
import 'package:wsp/features/meals/widgets/meals_header.dart';
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
  DateTime _weekStartDate = startOfWeek(DateTime.now());

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
      _weekStartDate = startOfWeek(DateTime.now());
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

  Future<MealDraft?> _showMealDialog({
    required List<Recipe> recipes,
    PlannedMeal? meal,
    DateTime? initialDate,
  }) {
    return showDialog<MealDraft>(
      context: context,
      builder: (_) {
        return MealDialog(
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
              return PageErrorView(
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
                  MealsHeader(
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
                    const EmptyStateCard(
                      icon: Icons.groups_outlined,
                      message: 'Najpierw utwórz albo wybierz grupę.',
                    )
                  else
                    for (final day in weekDays(_weekStartDate))
                      DayPlanCard(
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
    final normalizedDay = dateOnly(day);
    return meals.where((meal) => sameDay(meal.mealDate, normalizedDay)).toList()
      ..sort((a, b) => a.mealType.index.compareTo(b.mealType.index));
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
