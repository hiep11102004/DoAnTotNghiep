import '../entities/aicoaching_entity.dart';
import '../repository/aicoaching_repository.dart';

class GetCoachingsUseCase {
  final AICoachingRepository repository;

  GetCoachingsUseCase(this.repository);

  Future<List<AICoachingEntity>> call() async {
    return await repository.getCoachings();
  }
}
