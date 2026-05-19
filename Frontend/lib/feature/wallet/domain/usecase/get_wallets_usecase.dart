import '../entities/wallet_entity.dart';
import '../repository/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;

  GetWalletsUseCase(this.repository);

  Future<List<WalletEntity>> call() async {
    return await repository.getWallets();
  }
}
