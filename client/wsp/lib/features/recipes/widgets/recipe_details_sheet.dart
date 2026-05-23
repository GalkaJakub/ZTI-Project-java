import 'package:flutter/material.dart';
import 'package:wsp/features/recipes/models/recipe.dart';

class RecipeDetailsSheet extends StatelessWidget {
  const RecipeDetailsSheet({
    super.key,
    required this.recipe,
    required this.scrollController,
    required this.onEdit,
    required this.onDelete,
  });

  final Recipe recipe;
  final ScrollController scrollController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                recipe.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edytuj',
              onPressed: onEdit,
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(recipe.instructions),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Usuń przepis'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: const BorderSide(color: Color(0xFFFECACA)),
          ),
        ),
      ],
    );
  }
}
