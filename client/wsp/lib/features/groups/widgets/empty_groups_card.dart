import 'package:flutter/material.dart';

class EmptyGroupsCard extends StatelessWidget {
  const EmptyGroupsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.groups_2_outlined,
            size: 46,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(height: 14),
          Text(
            'Nie należysz jeszcze do żadnej grupy',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Utwórz grupę dla domowników albo dołącz do istniejącej kodem zaproszenia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), height: 1.4),
          ),
        ],
      ),
    );
  }
}
