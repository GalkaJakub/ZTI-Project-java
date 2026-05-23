import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/feature_header.dart';
import 'package:wsp/core/widgets/group_selector.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/meals/utils/meal_date_utils.dart';

class MealsHeader extends StatelessWidget {
  const MealsHeader({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.weekStartDate,
    required this.onGroupChanged,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onCurrentWeek,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final DateTime weekStartDate;
  final ValueChanged<int> onGroupChanged;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final weekEndDate = weekStartDate.add(const Duration(days: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FeatureHeader(icon: Icons.calendar_today, title: 'Plan tygodnia'),
        if (groups.isNotEmpty) ...[
          const SizedBox(height: 14),
          GroupSelector(
            groups: groups,
            selectedGroup: selectedGroup,
            onChanged: onGroupChanged,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Poprzedni tydzień',
                  onPressed: onPreviousWeek,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${formatShortDate(weekStartDate)} - ${formatShortDate(weekEndDate)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: onCurrentWeek,
                        child: const Text('Bieżący tydzień'),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Następny tydzień',
                  onPressed: onNextWeek,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
