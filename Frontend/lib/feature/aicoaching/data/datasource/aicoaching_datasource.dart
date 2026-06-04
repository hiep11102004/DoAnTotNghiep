import '../models/aicoaching_model.dart';

abstract class AICoachingDataSource {
  Future<AICoachingModel> getCoachings();
  Future<AICoachingModel> getCoachingById(String id);
  Future<AICoachingModel> createCoaching(AICoachingModel coaching);
  Future<AICoachingModel> updateCoaching(AICoachingModel coaching);
  Future<void> deleteCoaching(String id);
}
