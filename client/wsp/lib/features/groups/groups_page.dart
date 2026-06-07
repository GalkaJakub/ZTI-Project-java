import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/app_snack_bar.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_resolver.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/groups/widgets/empty_groups_card.dart';
import 'package:wsp/features/groups/widgets/group_actions.dart';
import 'package:wsp/features/groups/widgets/group_details_card.dart';
import 'package:wsp/features/groups/widgets/group_tile.dart';
import 'package:wsp/features/groups/widgets/groups_error.dart';
import 'package:wsp/features/groups/widgets/groups_header.dart';
import 'package:wsp/features/groups/widgets/groups_summary.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _groupService = GroupService();
  final _activeGroupResolver = ActiveGroupResolver();

  late Future<List<UserGroup>> _groupsFuture;
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _loadGroups();
  }

  Future<void> _refreshGroups() {
    final groupsFuture = _loadGroups();

    setState(() {
      _groupsFuture = groupsFuture;
    });

    return groupsFuture.then((_) {});
  }

  Future<List<UserGroup>> _loadGroups() async {
    final groupState = await _activeGroupResolver.resolve(
      preferredGroupId: _selectedGroupId,
    );
    _selectedGroupId = groupState.selectedGroup?.id;
    return groupState.groups;
  }

  Future<void> _createGroup() async {
    final name = await _showTextDialog(
      title: 'Nowa grupa',
      label: 'Nazwa grupy',
      hintText: 'np. Mieszkanie 12',
      icon: Icons.group_add_outlined,
    );

    if (name == null || name.isEmpty) {
      return;
    }

    try {
      final group = await _groupService.createGroup(name);

      if (!mounted) return;

      setState(() {
        _selectedGroupId = group.id;
      });
      await _activeGroupResolver.saveGroupId(group.id);
      await _refreshGroups();
      if (!mounted) return;
      context.showAppSnackBar('Grupa została utworzona.');
    } catch (e) {
      if (!mounted) return;
      context.showAppSnackBar('Nie udało się utworzyć grupy: $e');
    }
  }

  Future<void> _joinGroup() async {
    final inviteCode = await _showTextDialog(
      title: 'Dołącz do grupy',
      label: 'Kod zaproszenia',
      hintText: 'np. AB12CD34',
      icon: Icons.vpn_key_outlined,
      textCapitalization: TextCapitalization.characters,
    );

    if (inviteCode == null || inviteCode.isEmpty) {
      return;
    }

    try {
      final group = await _groupService.joinGroup(inviteCode);

      if (!mounted) return;

      setState(() {
        _selectedGroupId = group.id;
      });
      await _activeGroupResolver.saveGroupId(group.id);
      await _refreshGroups();
      if (!mounted) return;
      context.showAppSnackBar('Dołączono do grupy.');
    } catch (e) {
      if (!mounted) return;
      context.showAppSnackBar('Nie udało się dołączyć: $e');
    }
  }

  Future<void> _leaveGroup(UserGroup group) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Opuścić grupę "${group.name}"?'),
          content: const Text(
            'Po opuszczeniu grupy nie zobaczysz jej planu posiłków ani listy zakupów.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Opuść'),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true) {
      return;
    }

    try {
      await _groupService.leaveGroup(group.id);

      if (!mounted) return;

      setState(() {
        if (_selectedGroupId == group.id) {
          _selectedGroupId = null;
        }
      });
      await _refreshGroups();
      if (!mounted) return;
      context.showAppSnackBar('Opuszczono grupę.');
    } catch (e) {
      if (!mounted) return;
      context.showAppSnackBar('Nie udało się opuścić grupy: $e');
    }
  }

  Future<String?> _showTextDialog({
    required String title,
    required String label,
    required String hintText,
    required IconData icon,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) async {
    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 100,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              labelText: label,
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return value;
  }

  Future<void> _selectGroup(UserGroup group) async {
    setState(() {
      _selectedGroupId = group.id;
    });
    await _activeGroupResolver.saveGroupId(group.id);
  }

  UserGroup? _selectedGroup(List<UserGroup> groups) {
    if (groups.isEmpty) {
      return null;
    }

    final selectedId = _selectedGroupId;
    if (selectedId == null) {
      return groups.first;
    }

    for (final group in groups) {
      if (group.id == selectedId) {
        return group;
      }
    }

    return groups.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: FutureBuilder<List<UserGroup>>(
          future: _groupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return GroupsError(
                message: snapshot.error.toString(),
                onRetry: _refreshGroups,
              );
            }

            final groups = snapshot.requireData;
            final selectedGroup = _selectedGroup(groups);

            return RefreshIndicator(
              onRefresh: _refreshGroups,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const GroupsHeader(),
                  const SizedBox(height: 18),
                  GroupActions(
                    onCreateGroup: _createGroup,
                    onJoinGroup: _joinGroup,
                  ),
                  const SizedBox(height: 18),
                  if (groups.isEmpty)
                    const EmptyGroupsCard()
                  else ...[
                    GroupsSummary(groups: groups),
                    const SizedBox(height: 18),
                    Text(
                      'Twoje grupy',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final group in groups)
                      GroupTile(
                        group: group,
                        selected: selectedGroup?.id == group.id,
                        onTap: () => _selectGroup(group),
                      ),
                    if (selectedGroup != null) ...[
                      const SizedBox(height: 12),
                      GroupDetailsCard(
                        key: ValueKey(selectedGroup.id),
                        group: selectedGroup,
                        groupService: _groupService,
                        onLeave: () => _leaveGroup(selectedGroup),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
