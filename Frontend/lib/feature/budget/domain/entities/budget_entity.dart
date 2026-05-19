class BudgetEntity {
  final String id;
  final String userId;
  final String categoryId;
  final double limit;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;

  BudgetEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.limit,
    required this.spent,
    required this.startDate,
    required this.endDate,
  });
}
