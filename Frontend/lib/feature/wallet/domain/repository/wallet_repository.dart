import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getWallets();
  
  // 🛠️ Đổi String id thành int id cho khớp với WalletEntity
  Future<WalletEntity> getWalletById(int id);
  
  // 🛠️ Tách tham số cho dễ gọi từ Form nhập liệu
  Future<void> createWallet({
    required String name,
    required double initialBalance,
    required double currentBalance,
  });
  
  Future<WalletEntity> updateWallet(WalletEntity wallet);
  
  // 🛠️ Đổi String id thành int id
  Future<void> deleteWallet(int id);
}