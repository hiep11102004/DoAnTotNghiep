import 'package:flutter_bloc/flutter_bloc.dart';
import 'aicoaching_event.dart';
import 'aicoaching_state.dart';
import '../../domain/usecase/get_coachings_usecase.dart';

class AICoachingBloc extends Bloc<AICoachingEvent, AICoachingState> {
  final GetCoachingsUseCase getCoachingsUseCase;

  AICoachingBloc(this.getCoachingsUseCase) : super(AICoachingInitial()) {
    on<LoadAICoachingEvent>((event, emit) async {
      emit(AICoachingLoading());
      try {
        final data = await getCoachingsUseCase.call();
        emit(AICoachingLoaded(data));
      } catch (e) {
        emit(AICoachingError(e.toString()));
      }
    });
  }
}