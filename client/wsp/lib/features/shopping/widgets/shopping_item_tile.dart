import 'package:flutter/material.dart';
import 'package:wsp/features/shopping/models/shopping_item.dart';

class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

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
        leading: Checkbox(value: item.bought, onChanged: (_) => onToggle()),
        title: Text(
          item.name,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            decoration: item.bought ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(item.quantity),
        trailing: IconButton(
          tooltip: 'Usuń',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: const Color(0xFFDC2626),
        ),
      ),
    );
  }
}
