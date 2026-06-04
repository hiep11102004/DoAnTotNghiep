import '../entities/aicoaching_entity.dart';
import '../repository/aicoaching_repository.dart';

class GetCoachingsUseCase {
  final AICoachingRepository repository;

  GetCoachingsUseCase(this.repository);

  Future<AICoachingEntity> call() async {
    return await repository.getCoachings();
  }
}
