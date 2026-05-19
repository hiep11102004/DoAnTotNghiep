import '../../domain/entities/wallet_entity.dart';
import '../../domain/repository/wallet_repository.dart';
import '../datasource/wallet_datasource.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource dataSource;

  WalletRepositoryImpl({required this.dataSource});

  @override
  Future<List<WalletEntity>> getWallets() async {
    final wallets = await dataSource.getWallets();
    return wallets.map((wallet) => wallet as WalletEntity).toList();
  }

  @override
  Future<WalletEntity> getWalletById(String id) async {
    return await dataSource.getWalletById(id);
  }

  @override
  Future<WalletEntity> createWallet(WalletEntity wallet) async {
    final walletModel = WalletModel(
      id: wallet.id,
      userId: wallet.userId,
      name: wallet.name,
      balance: wallet.balance,
      currency: wallet.currency,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
    );
    return await dataSource.createWallet(walletModel);
  }

  @override
  Future<WalletEntity> updateWallet(WalletEntity wallet) async {
    final walletModel = WalletModel(
      id: wallet.id,
      userId: wallet.userId,
      name: wallet.name,
      balance: wallet.balance,
      currency: wallet.currency,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
    );
    return await dataSource.updateWallet(walletModel);
  }

  @override
  Future<void> deleteWallet(String id) async {
    await dataSource.deleteWallet(id);
  }
}
