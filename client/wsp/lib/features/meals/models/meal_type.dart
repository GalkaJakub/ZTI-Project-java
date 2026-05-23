enum MealType {
  breakfast('BREAKFAST', 'Śniadanie'),
  lunch('LUNCH', 'Lunch'),
  dinner('DINNER', 'Obiad'),
  supper('SUPPER', 'Kolacja');

  const MealType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static MealType fromApi(String value) {
    return MealType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => MealType.dinner,
    );
  }
}
