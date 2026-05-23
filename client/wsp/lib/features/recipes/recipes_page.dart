import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_storage.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/recipes/models/recipe.dart';
import 'package:wsp/features/recipes/models/recipe_ingredient.dart';
import 'package:wsp/features/recipes/services/recipe_service.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final _groupService = GroupService();
  final _recipeService = RecipeService();
  final _activeGroupStorage = ActiveGroupStorage();

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
    final groups = await _groupService.getGroups();
    final savedGroupId = await _activeGroupStorage.readActiveGroupId();

    if (groups.isEmpty) {
      _selectedGroupId = null;
      return const _RecipesPageData(
        groups: [],
        selectedGroup: null,
        recipes: [],
      );
    }

    final selectedGroup = _selectExistingGroup(
      groups: groups,
      preferredId: _selectedGroupId ?? savedGroupId,
    );

    _selectedGroupId = selectedGroup.id;
    await _activeGroupStorage.saveActiveGroupId(selectedGroup.id);

    final recipes = await _recipeService.getRecipes(selectedGroup.id);
    return _RecipesPageData(
      groups: groups,
      selectedGroup: selectedGroup,
      recipes: recipes,
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
      _showMessage('Dodano przepis.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się dodać przepisu: $e');
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
      _showMessage('Zapisano przepis.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się zapisać przepisu: $e');
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
      _showMessage('Usunięto przepis.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się usunąć przepisu: $e');
    }
  }

  Future<_RecipeDraft?> _showRecipeDialog({Recipe? recipe}) {
    return showDialog<_RecipeDraft>(
      context: context,
      builder: (context) => _RecipeDialog(recipe: recipe),
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
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edytuj',
                      onPressed: () {
                        Navigator.pop(context);
                        _editRecipe(recipe);
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
                if ((recipe.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(recipe.description!),
                ],
                const SizedBox(height: 18),
                Text(
                  'Składniki',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (recipe.ingredients.isEmpty)
                  const Text('Brak składników.')
                else
                  for (final ingredient in recipe.ingredients)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(ingredient.name),
                      trailing: Text(ingredient.quantity),
                    ),
                const SizedBox(height: 18),
                Text(
                  'Instrukcja',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recipe.instructions),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteRecipe(recipe);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Usuń przepis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFECACA)),
                  ),
                ),
              ],
            );
          },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRecipe,
        icon: const Icon(Icons.add),
        label: const Text('Przepis'),
      ),
      body: SafeArea(
        child: FutureBuilder<_RecipesPageData>(
          future: _pageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _RecipesError(
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
                  _RecipesHeader(
                    groups: data.groups,
                    selectedGroup: data.selectedGroup,
                    onGroupChanged: _changeGroup,
                  ),
                  const SizedBox(height: 18),
                  if (data.groups.isEmpty)
                    const _NoGroupCard()
                  else if (data.recipes.isEmpty)
                    const _EmptyRecipesCard()
                  else
                    for (final recipe in data.recipes)
                      _RecipeTile(
                        recipe: recipe,
                        onTap: () => _showRecipeDetails(recipe),
                        onEdit: () => _editRecipe(recipe),
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

class _RecipeDraft {
  const _RecipeDraft({
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

class _RecipesHeader extends StatelessWidget {
  const _RecipesHeader({
    required this.groups,
    required this.selectedGroup,
    required this.onGroupChanged,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final ValueChanged<int> onGroupChanged;

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.menu_book, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Przepisy',
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
        ],
      ],
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.recipe,
    required this.onTap,
    required this.onEdit,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEFF6FF),
          child: Icon(Icons.restaurant_menu, color: Color(0xFF2563EB)),
        ),
        title: Text(
          recipe.title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('${recipe.ingredients.length} składników'),
        trailing: IconButton(
          tooltip: 'Edytuj',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}

class _RecipeDialog extends StatefulWidget {
  const _RecipeDialog({this.recipe});

  final Recipe? recipe;

  @override
  State<_RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<_RecipeDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructionsController;
  late List<_IngredientControllers> _ingredients;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;

    _titleController = TextEditingController(text: recipe?.title ?? '');
    _descriptionController = TextEditingController(
      text: recipe?.description ?? '',
    );
    _instructionsController = TextEditingController(
      text: recipe?.instructions ?? '',
    );
    _ingredients = [
      for (final ingredient in recipe?.ingredients ?? <RecipeIngredient>[])
        _IngredientControllers(
          name: ingredient.name,
          quantity: ingredient.quantity,
        ),
    ];

    if (_ingredients.isEmpty) {
      _ingredients.add(_IngredientControllers());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientControllers());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length == 1) {
      _ingredients[index].clear();
      return;
    }

    setState(() {
      _ingredients.removeAt(index).dispose();
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final instructions = _instructionsController.text.trim();
    final ingredients = _ingredients
        .map((controllers) => controllers.toIngredient())
        .where(
          (ingredient) =>
              ingredient.name.isNotEmpty && ingredient.quantity.isNotEmpty,
        )
        .toList();

    if (title.isEmpty || instructions.isEmpty) {
      return;
    }

    Navigator.pop(
      context,
      _RecipeDraft(
        title: title,
        description: description,
        instructions: instructions,
        ingredients: ingredients,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.recipe == null ? 'Nowy przepis' : 'Edytuj przepis'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.restaurant_menu),
                  labelText: 'Nazwa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.notes_outlined),
                  labelText: 'Opis',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instructionsController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.format_list_numbered),
                  labelText: 'Instrukcja',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Składniki',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dodaj składnik',
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              for (var i = 0; i < _ingredients.length; i++) ...[
                _IngredientFields(
                  controllers: _ingredients[i],
                  onRemove: () => _removeIngredient(i),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
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

class _IngredientFields extends StatelessWidget {
  const _IngredientFields({required this.controllers, required this.onRemove});

  final _IngredientControllers controllers;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: controllers.nameController,
            decoration: const InputDecoration(
              labelText: 'Składnik',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controllers.quantityController,
            decoration: const InputDecoration(
              labelText: 'Ilość',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Usuń składnik',
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}

class _IngredientControllers {
  _IngredientControllers({String name = '', String quantity = ''})
    : nameController = TextEditingController(text: name),
      quantityController = TextEditingController(text: quantity);

  final TextEditingController nameController;
  final TextEditingController quantityController;

  RecipeIngredient toIngredient() {
    return RecipeIngredient(
      name: nameController.text.trim(),
      quantity: quantityController.text.trim(),
    );
  }

  void clear() {
    nameController.clear();
    quantityController.clear();
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}

class _EmptyRecipesCard extends StatelessWidget {
  const _EmptyRecipesCard();

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
          Icon(Icons.menu_book_outlined, color: Color(0xFF2563EB)),
          SizedBox(width: 12),
          Expanded(
            child: Text('Ta grupa nie ma jeszcze zapisanych przepisów.'),
          ),
        ],
      ),
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

class _RecipesError extends StatelessWidget {
  const _RecipesError({required this.message, required this.onRetry});

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
