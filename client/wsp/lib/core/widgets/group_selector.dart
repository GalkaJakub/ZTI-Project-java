import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/user_group.dart';

class GroupSelector extends StatelessWidget {
  const GroupSelector({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onChanged,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<int>(
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
          onChanged(value);
        }
      },
    );
  }
}
