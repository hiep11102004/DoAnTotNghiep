part of 'aicoaching_bloc.dart';

abstract class AICoachingEvent extends Equatable {
  const AICoachingEvent();

  @override
  List<Object?> get props => [];
}

class GetCoachingsEvent extends AICoachingEvent {
  const GetCoachingsEvent();
}

class CreateCoachingEvent extends AICoachingEvent {
  final AICoachingEntity coaching;

  const CreateCoachingEvent(this.coaching);

  @override
  List<Object?> get props => [coaching];
}

class UpdateCoachingEvent extends AICoachingEvent {
  final AICoachingEntity coaching;

  const UpdateCoachingEvent(this.coaching);

  @override
  List<Object?> get props => [coaching];
}

class DeleteCoachingEvent extends AICoachingEvent {
  final String coachingId;

  const DeleteCoachingEvent(this.coachingId);

  @override
  List<Object?> get props => [coachingId];
}
