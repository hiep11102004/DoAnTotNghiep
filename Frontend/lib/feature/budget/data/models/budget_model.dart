import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  BudgetModel({
    required String id,
    required String userId,
    required String categoryId,
    String categoryName = '',
    required double limit,
    required double spent,
    required DateTime startDate,
    required DateTime endDate,
  }) : super(
    id: id,
    userId: userId,
    categoryId: categoryId,
    categoryName: categoryName,
    limit: limit,
    spent: spent,
    startDate: startDate,
    endDate: endDate,
  );

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      limit: double.tryParse(json['amount_limit']?.toString() ?? '0') ?? 0.0,
      spent: double.tryParse(json['spent_amount']?.toString() ?? '0') ?? 0.0,
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'amount_limit': limit,
      'spent_amount': spent,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
