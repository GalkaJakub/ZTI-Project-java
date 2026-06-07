import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/app_snack_bar.dart';
import 'package:wsp/core/widgets/async_page_view.dart';
import 'package:wsp/core/widgets/empty_state_card.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_resolver.dart';
import 'package:wsp/features/recipes/models/recipe.dart';
import 'package:wsp/features/recipes/models/recipe_draft.dart';
import 'package:wsp/features/recipes/services/recipe_service.dart';
import 'package:wsp/features/recipes/widgets/recipe_details_sheet.dart';
import 'package:wsp/features/recipes/widgets/recipe_dialog.dart';
import 'package:wsp/features/recipes/widgets/recipe_tile.dart';
import 'package:wsp/features/recipes/widgets/recipes_header.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final _activeGroupResolver = ActiveGroupResolver();
  final _recipeService = RecipeService();

  late Future<_RecipesPageData> _pageFuture;
  int? _selectedGroupId;

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

  Future<_RecipesPageData> _loadPage() async {
    final groupState = await _activeGroupResolver.resolve(
      preferredGroupId: _selectedGroupId,
    );
    final selectedGroup = groupState.selectedGroup;
    _selectedGroupId = selectedGroup?.id;

    if (selectedGroup == null) {
      _selectedGroupId = null;
      return const _RecipesPageData(
        groups: [],
        selectedGroup: null,
        recipes: [],
      );
    }

    final recipes = await _recipeService.getRecipes(selectedGroup.id);
    return _RecipesPageData(
      groups: groupState.groups,
      selectedGroup: selectedGroup,
      recipes: recipes,
    );
  }

  Future<void> _changeGroup(int groupId) async {
    setState(() {
      _selectedGroupId = groupId;
      _pageFuture = _loadPage();
    });
    await _activeGroupResolver.saveGroupId(groupId);
  }

  Future<void> _createRecipe() async {
    final groupId = _selectedGroupId;
    if (groupId == null) {
      return;
    }

    final draft = await _showRecipeDialog();
    if (draft == null) {
      return;
    }

    try {
      await _recipeService.createRecipe(
        groupId: groupId,
        title: draft.title,
        description: draft.description,
        instructions: draft.instructions,
        ingredients: draft.ingredients,
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      context.showAppSnackBar('Dodano przepis.');
    } catch (e) {
      if (!mounted) return;
      context.showAppSnackBar('Nie udało się dodać przepisu: $e');
    }
  }

  Future<void> _editRecipe(Recipe recipe) async {
    final draft = await _showRecipeDialog(recipe: recipe);
    if (draft == null) {
      return;
    }

    try {
      await _recipeService.updateRecipe(
        groupId: recipe.groupId,
        recipeId: recipe.id,
        title: draft.title,
        description: draft.description,
        instructions: draft.instructions,
        ingredients: draft.ingredients,
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      context.showAppSnackBar('Zapisano przepis.');
    } catch (e) {
      if (!mounted) return;
      context.showAppSnackBar('Nie udało się zapisać przepisu: $e');
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Usunąć "${recipe.title}"?'),
          content: const Text('Tego przepisu nie będzie można odzyskać.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _recipeService.deleteRecipe(
        groupId: recipe.groupId,
        recipeId: recipe.id,
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      context.showAppSnackBar('Usunięto przepis.');
    } catch (e) {
      if (!mounted) return;
      context.showAppSnackBar('Nie udało się usunąć przepisu: $e');
    }
  }

  Future<RecipeDraft?> _showRecipeDialog({Recipe? recipe}) {
    return showDialog<RecipeDraft>(
      context: context,
      builder: (_) => RecipeDialog(recipe: recipe),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return RecipeDetailsSheet(
              recipe: recipe,
              scrollController: scrollController,
              onEdit: () {
                Navigator.pop(context);
                _editRecipe(recipe);
              },
              onDelete: () {
                Navigator.pop(context);
                _deleteRecipe(recipe);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRecipe,
        icon: const Icon(Icons.add),
        label: const Text('Przepis'),
      ),
      body: AsyncPageView<_RecipesPageData>(
        future: _pageFuture,
        onRefresh: _refresh,
        builder: (context, data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RecipesHeader(
              groups: data.groups,
              selectedGroup: data.selectedGroup,
              onGroupChanged: _changeGroup,
            ),
            const SizedBox(height: 18),
            if (data.groups.isEmpty)
              const EmptyStateCard(
                icon: Icons.groups_outlined,
                message: 'Najpierw utwórz albo wybierz grupę.',
              )
            else if (data.recipes.isEmpty)
              const EmptyStateCard(
                icon: Icons.menu_book_outlined,
                message: 'Ta grupa nie ma jeszcze zapisanych przepisów.',
              )
            else
              for (final recipe in data.recipes)
                RecipeTile(
                  recipe: recipe,
                  onTap: () => _showRecipeDetails(recipe),
                  onEdit: () => _editRecipe(recipe),
                ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}

class _RecipesPageData {
  const _RecipesPageData({
    required this.groups,
    required this.selectedGroup,
    required this.recipes,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final List<Recipe> recipes;
}
