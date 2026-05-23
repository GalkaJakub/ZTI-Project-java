import 'package:flutter/material.dart';
import 'package:wsp/features/recipes/models/recipe.dart';
import 'package:wsp/features/recipes/models/recipe_draft.dart';
import 'package:wsp/features/recipes/models/recipe_ingredient.dart';

class RecipeDialog extends StatefulWidget {
  const RecipeDialog({super.key, this.recipe});

  final Recipe? recipe;

  @override
  State<RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<RecipeDialog> {
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
      RecipeDraft(
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
