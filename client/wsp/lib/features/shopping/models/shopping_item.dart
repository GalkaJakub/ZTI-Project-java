class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.groupId,
    required this.name,
    required this.quantity,
    required this.bought,
  });

  final int id;
  final int groupId;
  final String name;
  final String quantity;
  final bool bought;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as int,
      groupId: json['groupId'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      bought: json['bought'] as bool,
    );
  }
}
