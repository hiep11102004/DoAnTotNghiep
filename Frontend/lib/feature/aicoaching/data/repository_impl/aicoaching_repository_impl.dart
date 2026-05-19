import '../../domain/entities/aicoaching_entity.dart';
import '../../domain/repository/aicoaching_repository.dart';
import '../datasource/aicoaching_datasource.dart';
import '../models/aicoaching_model.dart';

class AICoachingRepositoryImpl implements AICoachingRepository {
  final AICoachingDataSource dataSource;

  AICoachingRepositoryImpl({required this.dataSource});

  @override
  Future<List<AICoachingEntity>> getCoachings() async {
    final coachings = await dataSource.getCoachings();
    return coachings.map((coaching) => coaching as AICoachingEntity).toList();
  }

  @override
  Future<AICoachingEntity> getCoachingById(String id) async {
    return await dataSource.getCoachingById(id);
  }

  @override
  Future<AICoachingEntity> createCoaching(AICoachingEntity coaching) async {
    final coachingModel = AICoachingModel(
      id: coaching.id,
      userId: coaching.userId,
      topic: coaching.topic,
      description: coaching.description,
      content: coaching.content,
      tips: coaching.tips,
      createdAt: coaching.createdAt,
      updatedAt: coaching.updatedAt,
    );
    return await dataSource.createCoaching(coachingModel);
  }

  @override
  Future<AICoachingEntity> updateCoaching(AICoachingEntity coaching) async {
    final coachingModel = AICoachingModel(
      id: coaching.id,
      userId: coaching.userId,
      topic: coaching.topic,
      description: coaching.description,
      content: coaching.content,
      tips: coaching.tips,
      createdAt: coaching.createdAt,
      updatedAt: coaching.updatedAt,
    );
    return await dataSource.updateCoaching(coachingModel);
  }

  @override
  Future<void> deleteCoaching(String id) async {
    await dataSource.deleteCoaching(id);
  }
}
