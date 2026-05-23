import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/feature_header.dart';
import 'package:wsp/core/widgets/group_selector.dart';
import 'package:wsp/features/groups/models/user_group.dart';

class RecipesHeader extends StatelessWidget {
  const RecipesHeader({
    super.key,
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
        const FeatureHeader(icon: Icons.menu_book, title: 'Przepisy'),
        if (groups.isNotEmpty) ...[
          const SizedBox(height: 14),
          GroupSelector(
            groups: groups,
            selectedGroup: selectedGroup,
            onChanged: onGroupChanged,
          ),
        ],
      ],
    );
  }
}
