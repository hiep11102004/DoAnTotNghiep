import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/usecase/get_budgets_usecase.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetsUseCase getBudgetsUseCase;

  BudgetBloc({
    required this.getBudgetsUseCase,
  }) : super(const BudgetInitial()) {
    on<GetBudgetsEvent>(_onGetBudgets);
  }

  Future<void> _onGetBudgets(
    GetBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());
    try {
      final budgets = await getBudgetsUseCase();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
