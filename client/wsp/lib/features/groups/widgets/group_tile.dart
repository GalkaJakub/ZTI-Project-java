import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/user_group.dart';

class GroupTile extends StatelessWidget {
  const GroupTile({
    super.key,
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final UserGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: selected
              ? const Color(0xFF2563EB)
              : const Color(0xFFEFF6FF),
          child: Icon(
            Icons.groups_outlined,
            color: selected ? Colors.white : const Color(0xFF2563EB),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
