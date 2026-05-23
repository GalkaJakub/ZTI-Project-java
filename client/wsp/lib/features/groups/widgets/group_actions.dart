import 'package:flutter/material.dart';

class GroupActions extends StatelessWidget {
  const GroupActions({
    super.key,
    required this.onCreateGroup,
    required this.onJoinGroup,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onCreateGroup,
            icon: const Icon(Icons.add),
            label: const Text('Utwórz'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onJoinGroup,
            icon: const Icon(Icons.vpn_key_outlined),
            label: const Text('Dołącz'),
          ),
        ),
      ],
    );
  }
}
