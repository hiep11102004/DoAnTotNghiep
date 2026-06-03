import '../../domain/entities/budget_entity.dart';

abstract class BudgetState {}
class BudgetInitial extends BudgetState {}
class BudgetLoading extends BudgetState {}
class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  BudgetLoaded(this.budgets);
}
class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);
}