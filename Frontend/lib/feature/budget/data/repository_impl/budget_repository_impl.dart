import '../../domain/entities/budget_entity.dart';
import '../../domain/repository/budget_repository.dart';
import '../datasource/budget_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDataSource dataSource;

  BudgetRepositoryImpl({required this.dataSource});

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final budgets = await dataSource.getBudgets();
    return budgets.map((budget) => budget as BudgetEntity).toList();
  }

  @override
  Future<BudgetEntity> getBudgetById(String id) async {
    return await dataSource.getBudgetById(id);
  }

  @override
  Future<BudgetEntity> createBudget(BudgetEntity budget) async {
    final budgetModel = BudgetModel(
      id: budget.id,
      userId: budget.userId,
      categoryId: budget.categoryId,
      limit: budget.limit,
      spent: budget.spent,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );
    return await dataSource.createBudget(budgetModel);
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    final budgetModel = BudgetModel(
      id: budget.id,
      userId: budget.userId,
      categoryId: budget.categoryId,
      limit: budget.limit,
      spent: budget.spent,
      startDate: budget.startDate,
      endDate: budget.endDate,
    );
    return await dataSource.updateBudget(budgetModel);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await dataSource.deleteBudget(id);
  }
}
