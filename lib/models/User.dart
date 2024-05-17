class User {
  final String name;
  final String location;
  final DateTime? date;
  final Map<String, num> readings;
  final Map<String, num> usage;
  final Map<String, num> excessConsumed;
  final Map<String, num> minimumBill;
  final Map<String, num> excessBill;
  final DateTime? dueDate;

  User({
    required this.name,
    required this.location,
    this.date,
    required this.readings,
    required this.usage,
    required this.excessConsumed,
    required this.minimumBill,
    this.dueDate,
    required this.excessBill,
  });
}