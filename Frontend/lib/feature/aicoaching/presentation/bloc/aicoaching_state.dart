part of 'aicoaching_bloc.dart';

abstract class AICoachingState extends Equatable {
  const AICoachingState();

  @override
  List<Object?> get props => [];
}

class AICoachingInitial extends AICoachingState {
  const AICoachingInitial();
}

class AICoachingLoading extends AICoachingState {
  const AICoachingLoading();
}

class AICoachingLoaded extends AICoachingState {
  final List<AICoachingEntity> coachings;

  const AICoachingLoaded(this.coachings);

  @override
  List<Object?> get props => [coachings];
}

class AICoachingError extends AICoachingState {
  final String message;

  const AICoachingError(this.message);

  @override
  List<Object?> get props => [message];
}
