abstract class AICoachingEvent {}

class LoadAICoachingEvent extends AICoachingEvent {}

class LoadAITasksEvent extends AICoachingEvent {}

class CompleteAITaskEvent extends AICoachingEvent {
  final int taskId;
  CompleteAITaskEvent(this.taskId);
}

class LoadChallengesEvent extends AICoachingEvent {}

class JoinChallengeEvent extends AICoachingEvent {
  final int challengeId;
  JoinChallengeEvent(this.challengeId);
}

class LoadBadgesEvent extends AICoachingEvent {}