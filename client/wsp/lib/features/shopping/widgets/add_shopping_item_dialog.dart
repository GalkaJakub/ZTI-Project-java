import 'package:flutter/material.dart';
import 'package:wsp/features/shopping/models/new_shopping_item.dart';

class AddShoppingItemDialog extends StatefulWidget {
  const AddShoppingItemDialog({super.key});

  @override
  State<AddShoppingItemDialog> createState() => _AddShoppingItemDialogState();
}

class _AddShoppingItemDialogState extends State<AddShoppingItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();

    if (name.isEmpty || quantity.isEmpty) {
      return;
    }

    Navigator.pop(context, NewShoppingItem(name: name, quantity: quantity));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowy produkt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.shopping_bag_outlined),
              labelText: 'Produkt',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.scale_outlined),
              labelText: 'Ilość',
              hintText: 'np. 2 kg',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Dodaj')),
      ],
    );
  }
}
