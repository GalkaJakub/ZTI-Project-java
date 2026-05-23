import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/group_member.dart';

class MemberTile extends StatelessWidget {
  const MemberTile({super.key, required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEFF6FF),
        child: Text(
          member.initials,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(member.displayName),
      subtitle: Text(member.email),
    );
  }
}
