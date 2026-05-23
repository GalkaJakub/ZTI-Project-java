class RecipeIngredient {
  const RecipeIngredient({this.id, required this.name, required this.quantity});

  final int? id;
  final String name;
  final String quantity;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as int?,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name.trim(), 'quantity': quantity.trim()};
  }
}
