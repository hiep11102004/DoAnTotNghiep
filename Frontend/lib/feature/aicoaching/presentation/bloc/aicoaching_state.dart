import '../../domain/entities/aicoaching_entity.dart';
import '../../data/models/aicoaching_model.dart';

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

// AI Tasks
class AITasksLoading extends AICoachingState {}

class AITasksLoaded extends AICoachingState {
  final List<AITaskModel> tasks;
  AITasksLoaded(this.tasks);
}

class AITasksError extends AICoachingState {
  final String message;
  AITasksError(this.message);
}

// Challenges
class ChallengesLoading extends AICoachingState {}

class ChallengesLoaded extends AICoachingState {
  final List<ChallengeModel> challenges;
  ChallengesLoaded(this.challenges);
}

class ChallengesError extends AICoachingState {
  final String message;
  ChallengesError(this.message);
}

class ChallengeActionSuccess extends AICoachingState {
  final String message;
  ChallengeActionSuccess(this.message);
}

// Badges
class BadgesLoading extends AICoachingState {}

class BadgesLoaded extends AICoachingState {
  final List<BadgeModel> badges;
  BadgesLoaded(this.badges);
}

class BadgesError extends AICoachingState {
  final String message;
  BadgesError(this.message);
}