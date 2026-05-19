import '../entities/budget_entity.dart';
import '../repository/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  Future<List<BudgetEntity>> call() async {
    return await repository.getBudgets();
  }
}
