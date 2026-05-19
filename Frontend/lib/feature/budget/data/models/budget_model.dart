import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  BudgetModel({
    required String id,
    required String userId,
    required String categoryId,
    required double limit,
    required double spent,
    required DateTime startDate,
    required DateTime endDate,
  }) : super(
    id: id,
    userId: userId,
    categoryId: categoryId,
    limit: limit,
    spent: spent,
    startDate: startDate,
    endDate: endDate,
  );

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'limit': limit,
      'spent': spent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
