DateTime startOfWeek(DateTime date) {
  final dateOnlyValue = dateOnly(date);
  return dateOnlyValue.subtract(Duration(days: dateOnlyValue.weekday - 1));
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

List<DateTime> weekDays(DateTime weekStartDate) {
  return List.generate(7, (index) => weekStartDate.add(Duration(days: index)));
}

String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month';
}

String weekdayLabel(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'Poniedziałek',
    DateTime.tuesday => 'Wtorek',
    DateTime.wednesday => 'Środa',
    DateTime.thursday => 'Czwartek',
    DateTime.friday => 'Piątek',
    DateTime.saturday => 'Sobota',
    DateTime.sunday => 'Niedziela',
    _ => '',
  };
}
