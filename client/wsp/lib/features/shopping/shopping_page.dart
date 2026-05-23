import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/empty_state_card.dart';
import 'package:wsp/core/widgets/page_error_view.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_storage.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/shopping/models/new_shopping_item.dart';
import 'package:wsp/features/shopping/models/shopping_item.dart';
import 'package:wsp/features/shopping/services/shopping_service.dart';
import 'package:wsp/features/shopping/widgets/add_shopping_item_dialog.dart';
import 'package:wsp/features/shopping/widgets/shopping_header.dart';
import 'package:wsp/features/shopping/widgets/shopping_item_tile.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final _groupService = GroupService();
  final _shoppingService = ShoppingService();
  final _activeGroupStorage = ActiveGroupStorage();

  late Future<_ShoppingPageData> _pageFuture;
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _pageFuture = _loadPage();
  }

  Future<void> _refresh() {
    final pageFuture = _loadPage();

    setState(() {
      _pageFuture = pageFuture;
    });

    return pageFuture.then((_) {});
  }

  Future<_ShoppingPageData> _loadPage() async {
    final groups = await _groupService.getGroups();
    final savedGroupId = await _activeGroupStorage.readActiveGroupId();

    if (groups.isEmpty) {
      _selectedGroupId = null;
      return const _ShoppingPageData(
        groups: [],
        selectedGroup: null,
        items: [],
      );
    }

    final selectedGroup = _selectExistingGroup(
      groups: groups,
      preferredId: _selectedGroupId ?? savedGroupId,
    );

    _selectedGroupId = selectedGroup.id;
    await _activeGroupStorage.saveActiveGroupId(selectedGroup.id);

    final items = await _shoppingService.getItems(selectedGroup.id);
    return _ShoppingPageData(
      groups: groups,
      selectedGroup: selectedGroup,
      items: items,
    );
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

  Future<void> _changeGroup(int groupId) async {
    setState(() {
      _selectedGroupId = groupId;
      _pageFuture = _loadPage();
    });
    await _activeGroupStorage.saveActiveGroupId(groupId);
  }

  Future<void> _addItem() async {
    final groupId = _selectedGroupId;
    if (groupId == null) {
      return;
    }

    final item = await _showAddItemDialog();
    if (item == null) {
      return;
    }

    try {
      await _shoppingService.createItem(
        groupId: groupId,
        name: item.name,
        quantity: item.quantity,
      );
      if (!mounted) return;
      await _refresh();
      _showMessage('Dodano produkt.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się dodać produktu: $e');
    }
  }

  Future<void> _toggleItem(ShoppingItem item) async {
    try {
      await _shoppingService.toggleItem(groupId: item.groupId, itemId: item.id);
      if (!mounted) return;
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się zmienić statusu: $e');
    }
  }

  Future<void> _deleteItem(ShoppingItem item) async {
    try {
      await _shoppingService.deleteItem(groupId: item.groupId, itemId: item.id);
      if (!mounted) return;
      await _refresh();
      _showMessage('Usunięto produkt.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Nie udało się usunąć produktu: $e');
    }
  }

  Future<NewShoppingItem?> _showAddItemDialog() async {
    return showDialog<NewShoppingItem>(
      context: context,
      builder: (_) => const AddShoppingItemDialog(),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Produkt'),
      ),
      body: SafeArea(
        child: FutureBuilder<_ShoppingPageData>(
          future: _pageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return PageErrorView(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final data = snapshot.requireData;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ShoppingHeader(
                    groups: data.groups,
                    selectedGroup: data.selectedGroup,
                    onGroupChanged: _changeGroup,
                  ),
                  const SizedBox(height: 18),
                  if (data.groups.isEmpty)
                    const EmptyStateCard(
                      icon: Icons.groups_outlined,
                      message: 'Najpierw utwórz albo wybierz grupę.',
                    )
                  else if (data.items.isEmpty)
                    const EmptyStateCard(
                      icon: Icons.playlist_add_check,
                      message: 'Lista tej grupy jest pusta.',
                    )
                  else
                    for (final item in data.items)
                      ShoppingItemTile(
                        item: item,
                        onToggle: () => _toggleItem(item),
                        onDelete: () => _deleteItem(item),
                      ),
                  const SizedBox(height: 88),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShoppingPageData {
  const _ShoppingPageData({
    required this.groups,
    required this.selectedGroup,
    required this.items,
  });

  final List<UserGroup> groups;
  final UserGroup? selectedGroup;
  final List<ShoppingItem> items;
}
