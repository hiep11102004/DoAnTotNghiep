import '../entities/aicoaching_entity.dart';

abstract class AICoachingRepository {
  Future<List<AICoachingEntity>> getCoachings();
  Future<AICoachingEntity> getCoachingById(String id);
  Future<AICoachingEntity> createCoaching(AICoachingEntity coaching);
  Future<AICoachingEntity> updateCoaching(AICoachingEntity coaching);
  Future<void> deleteCoaching(String id);
}
