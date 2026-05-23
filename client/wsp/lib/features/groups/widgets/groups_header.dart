import 'package:flutter/material.dart';

class GroupsHeader extends StatelessWidget {
  const GroupsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grupy',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
