import '../../domain/entities/aicoaching_entity.dart';

abstract class AICoachingState {}

class AICoachingInitial extends AICoachingState {}

class AICoachingLoading extends AICoachingState {}

class AICoachingLoaded extends AICoachingState {
  final AICoachingEntity coachingData;
  AICoachingLoaded(this.coachingData);
}

class AICoachingError extends AICoachingState {
  final String message;
  AICoachingError(this.message);
}