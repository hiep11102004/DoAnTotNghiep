import 'package:flutter_bloc/flutter_bloc.dart';
import 'aicoaching_event.dart';
import 'aicoaching_state.dart';
import '../../domain/usecase/get_coachings_usecase.dart';
import '../../data/datasource/ai_datasource.dart';

class AICoachingBloc extends Bloc<AICoachingEvent, AICoachingState> {
  final GetCoachingsUseCase getCoachingsUseCase;
  final AIDatasource aiDatasource;

  AICoachingBloc(this.getCoachingsUseCase, this.aiDatasource) : super(AICoachingInitial()) {

    on<LoadAICoachingEvent>((event, emit) async {
      emit(AICoachingLoading());
      try {
        final data = await getCoachingsUseCase.call();
        emit(AICoachingLoaded(data));
      } catch (e) {
        emit(AICoachingError(e.toString()));
      }
    });

    on<LoadAITasksEvent>((event, emit) async {
      emit(AITasksLoading());
      try {
        final tasks = await aiDatasource.getTasks();
        emit(AITasksLoaded(tasks));
      } catch (e) {
        emit(AITasksError(e.toString()));
      }
    });

    on<CompleteAITaskEvent>((event, emit) async {
      try {
        final xp = await aiDatasource.completeTask(event.taskId);
        emit(TaskCompleteSuccess('+$xp XP nhận được!', xp));
        add(LoadAITasksEvent());
      } catch (e) {
        emit(AITasksError(e.toString()));
      }
    });

    on<LoadChallengesEvent>((event, emit) async {
      emit(ChallengesLoading());
      try {
        final challenges = await aiDatasource.getChallenges();
        emit(ChallengesLoaded(challenges));
      } catch (e) {
        emit(ChallengesError(e.toString()));
      }
    });

    on<JoinChallengeEvent>((event, emit) async {
      try {
        await aiDatasource.joinChallenge(event.challengeId);
        emit(ChallengeActionSuccess('Tham gia thử thách thành công!'));
        add(LoadChallengesEvent());
      } catch (e) {
        emit(ChallengesError(e.toString()));
      }
    });

    on<LoadBadgesEvent>((event, emit) async {
      emit(BadgesLoading());
      try {
        final badges = await aiDatasource.getBadges();
        emit(BadgesLoaded(badges));
      } catch (e) {
        emit(BadgesError(e.toString()));
      }
    });
  }
}