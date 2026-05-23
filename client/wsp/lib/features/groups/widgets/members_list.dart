import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/group_member.dart';
import 'package:wsp/features/groups/widgets/inline_error.dart';
import 'package:wsp/features/groups/widgets/member_tile.dart';

class MembersList extends StatelessWidget {
  const MembersList({
    super.key,
    required this.membersFuture,
    required this.onRetry,
  });

  final Future<List<GroupMember>> membersFuture;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GroupMember>>(
      future: membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return InlineError(
            message: snapshot.error.toString(),
            onRetry: onRetry,
          );
        }

        final members = snapshot.requireData;
        return Column(
          children: [for (final member in members) MemberTile(member: member)],
        );
      },
    );
  }
}
