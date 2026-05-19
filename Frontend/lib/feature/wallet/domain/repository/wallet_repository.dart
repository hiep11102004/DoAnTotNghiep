import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getWallets();
  Future<WalletEntity> getWalletById(String id);
  Future<WalletEntity> createWallet(WalletEntity wallet);
  Future<WalletEntity> updateWallet(WalletEntity wallet);
  Future<void> deleteWallet(String id);
}
