import 'package:flutter/material.dart';
import 'package:wsp/features/groups/models/user_group.dart';
import 'package:wsp/features/groups/services/active_group_storage.dart';
import 'package:wsp/features/groups/services/group_service.dart';
import 'package:wsp/features/shopping/models/shopping_item.dart';
import 'package:wsp/features/shopping/services/shopping_service.dart';

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

  Future<_NewShoppingItem?> _showAddItemDialog() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    final item = await showDialog<_NewShoppingItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nowy produkt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  labelText: 'Produkt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.scale_outlined),
                  labelText: 'Ilość',
                  hintText: 'np. 2 kg',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final quantity = quantityController.text.trim();

                if (name.isEmpty || quantity.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  _NewShoppingItem(name: name, quantity: quantity),
                );
              },
              child: const Text('Dodaj'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    quantityController.dispose();
    return item;
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
              return _ShoppingError(
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
                  _ShoppingHeader(
                    groups: data.groups,
                    selectedGroup: data.selectedGroup,
                    onGroupChanged: _changeGroup,
                  ),
                  const SizedBox(height: 18),
                  if (data.groups.isEmpty)
                    const _NoGroupCard()
                  else if (data.items.isEmpty)
                    const _EmptyShoppingList()
                  else
                    for (final item in data.items)
                      _ShoppingItemTile(
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

class _NewShoppingItem {
  const _NewShoppingItem({required this.name, required this.quantity});

  final String name;
  final String quantity;
}

class _ShoppingHeader extends StatelessWidget {
  const _ShoppingHeader({
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
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lista zakupów',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (groups.isNotEmpty) ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
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
                onGroupChanged(value);
              }
            },
          ),
        ],
      ],
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  const _ShoppingItemTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Checkbox(value: item.bought, onChanged: (_) => onToggle()),
        title: Text(
          item.name,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            decoration: item.bought ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(item.quantity),
        trailing: IconButton(
          tooltip: 'Usuń',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

class _EmptyShoppingList extends StatelessWidget {
  const _EmptyShoppingList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.playlist_add_check, color: Color(0xFF2563EB)),
          SizedBox(width: 12),
          Expanded(child: Text('Lista tej grupy jest pusta.')),
        ],
      ),
    );
  }
}

class _NoGroupCard extends StatelessWidget {
  const _NoGroupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.groups_outlined, color: Color(0xFF2563EB)),
          SizedBox(width: 12),
          Expanded(child: Text('Najpierw utwórz albo wybierz grupę.')),
        ],
      ),
    );
  }
}

class _ShoppingError extends StatelessWidget {
  const _ShoppingError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}
