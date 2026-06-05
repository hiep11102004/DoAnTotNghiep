import 'package:flutter_bloc/flutter_bloc.dart';
import 'saving_goal_datasource.dart';

// ---- EVENTS ----
abstract class SavingGoalEvent {}

class FetchSavingGoals extends SavingGoalEvent {}

class AddSavingGoal extends SavingGoalEvent {
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final String? deadline;

  AddSavingGoal({
    required this.goalName,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
  });
}

class UpdateSavingGoal extends SavingGoalEvent {
  final int id;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final String? deadline;
  final String status;

  UpdateSavingGoal({
    required this.id,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.status,
  });
}

class DeleteSavingGoal extends SavingGoalEvent {
  final int id;
  DeleteSavingGoal(this.id);
}

// ---- STATES ----
abstract class SavingGoalState {}

class SavingGoalInitial extends SavingGoalState {}

class SavingGoalLoading extends SavingGoalState {}

class SavingGoalLoaded extends SavingGoalState {
  final List<SavingGoalModel> goals;
  SavingGoalLoaded(this.goals);
}

class SavingGoalActionSuccess extends SavingGoalState {
  final String message;
  SavingGoalActionSuccess(this.message);
}

class SavingGoalError extends SavingGoalState {
  final String message;
  SavingGoalError(this.message);
}

// ---- BLOC ----
class SavingGoalBloc extends Bloc<SavingGoalEvent, SavingGoalState> {
  final SavingGoalDatasource datasource;

  SavingGoalBloc(this.datasource) : super(SavingGoalInitial()) {

    on<FetchSavingGoals>((event, emit) async {
      emit(SavingGoalLoading());
      try {
        final goals = await datasource.getGoals();
        emit(SavingGoalLoaded(goals));
      } catch (e) {
        emit(SavingGoalError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<AddSavingGoal>((event, emit) async {
      try {
        await datasource.createGoal({
          'goal_name': event.goalName,
          'target_amount': event.targetAmount,
          'current_amount': event.currentAmount,
          if (event.deadline != null) 'deadline': event.deadline,
        });
        emit(SavingGoalActionSuccess('Đã thêm mục tiêu thành công!'));
        add(FetchSavingGoals());
      } catch (e) {
        emit(SavingGoalError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateSavingGoal>((event, emit) async {
      try {
        await datasource.updateGoal(event.id, {
          'goal_name': event.goalName,
          'target_amount': event.targetAmount,
          'current_amount': event.currentAmount,
          if (event.deadline != null) 'deadline': event.deadline,
          'status': event.status,
        });
        emit(SavingGoalActionSuccess('Đã cập nhật mục tiêu!'));
        add(FetchSavingGoals());
      } catch (e) {
        emit(SavingGoalError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<DeleteSavingGoal>((event, emit) async {
      try {
        await datasource.deleteGoal(event.id);
        emit(SavingGoalActionSuccess('Đã xóa mục tiêu!'));
        add(FetchSavingGoals());
      } catch (e) {
        emit(SavingGoalError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
