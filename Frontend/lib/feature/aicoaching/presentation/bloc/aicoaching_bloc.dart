import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/aicoaching_entity.dart';
import '../../domain/usecase/get_coachings_usecase.dart';

part 'aicoaching_event.dart';
part 'aicoaching_state.dart';

class AICoachingBloc extends Bloc<AICoachingEvent, AICoachingState> {
  final GetCoachingsUseCase getCoachingsUseCase;

  AICoachingBloc({
    required this.getCoachingsUseCase,
  }) : super(const AICoachingInitial()) {
    on<GetCoachingsEvent>(_onGetCoachings);
  }

  Future<void> _onGetCoachings(
    GetCoachingsEvent event,
    Emitter<AICoachingState> emit,
  ) async {
    emit(const AICoachingLoading());
    try {
      final coachings = await getCoachingsUseCase();
      emit(AICoachingLoaded(coachings));
    } catch (e) {
      emit(AICoachingError(e.toString()));
    }
  }
}
