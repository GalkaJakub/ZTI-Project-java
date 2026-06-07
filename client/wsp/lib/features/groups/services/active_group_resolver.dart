import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_storage.dart';
import 'package:wsp/features/groups/services/group_service.dart';

class ActiveGroupResolver {
  ActiveGroupResolver({
    GroupService? groupService,
    ActiveGroupStorage? activeGroupStorage,
  }) : _groupService = groupService ?? GroupService(),
       _activeGroupStorage = activeGroupStorage ?? ActiveGroupStorage();

  final GroupService _groupService;
  final ActiveGroupStorage _activeGroupStorage;

  Future<ActiveGroupState> resolve({int? preferredGroupId}) async {
    final groups = await _groupService.getGroups();
    final savedGroupId = await _activeGroupStorage.readActiveGroupId();

    if (groups.isEmpty) {
      await _activeGroupStorage.clear();
      return const ActiveGroupState(groups: [], selectedGroup: null);
    }

    final selectedGroup = _selectExistingGroup(
      groups: groups,
      preferredId: preferredGroupId ?? savedGroupId,
    );
    await _activeGroupStorage.saveActiveGroupId(selectedGroup.id);

    return ActiveGroupState(groups: groups, selectedGroup: selectedGroup);
  }

  Future<void> saveGroupId(int groupId) {
    return _activeGroupStorage.saveActiveGroupId(groupId);
  }

  UserGroup _selectExistingGroup({
    required List<UserGroup> groups,
    required int? preferredId,
  }) {
    for (final group in groups) {
      if (group.id == preferredId) {
        return group;
      }
    }

    return groups.first;
  }
}

class ActiveGroupState {
  const ActiveGroupState({required this.groups, required this.selectedGroup});

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
}
