import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wsp/core/widgets/app_snack_bar.dart';
import 'package:wsp/features/groups/models/group_member.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/groups/widgets/invite_code_box.dart';
import 'package:wsp/features/groups/widgets/members_list.dart';

class GroupDetailsCard extends StatefulWidget {
  const GroupDetailsCard({
    super.key,
    required this.group,
    required this.groupService,
    required this.onLeave,
  });

  final UserGroup group;
  final GroupService groupService;
  final VoidCallback onLeave;

  @override
  State<GroupDetailsCard> createState() => _GroupDetailsCardState();
}

class _GroupDetailsCardState extends State<GroupDetailsCard> {
  late Future<List<GroupMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = widget.groupService.getMembers(widget.group.id);
  }

  Future<void> _refreshMembers() {
    final membersFuture = widget.groupService.getMembers(widget.group.id);

    setState(() {
      _membersFuture = membersFuture;
    });

    return membersFuture.then((_) {});
  }

  Future<void> _copyInviteCode() async {
    await Clipboard.setData(ClipboardData(text: widget.group.inviteCode));

    if (!mounted) return;
    context.showAppSnackBar('Kod zaproszenia skopiowany.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupTitle(group: widget.group, onRefreshMembers: _refreshMembers),
          const SizedBox(height: 16),
          InviteCodeBox(
            inviteCode: widget.group.inviteCode,
            onCopy: _copyInviteCode,
          ),
          const SizedBox(height: 18),
          Text(
            'Członkowie',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          MembersList(membersFuture: _membersFuture, onRetry: _refreshMembers),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLeave,
              icon: const Icon(Icons.logout),
              label: const Text('Opuść grupę'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFECACA)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.group, required this.onRefreshMembers});

  final UserGroup group;
  final VoidCallback onRefreshMembers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Odśwież członków',
          onPressed: onRefreshMembers,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
