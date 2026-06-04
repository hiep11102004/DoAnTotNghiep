import '../../domain/entities/wallet_entity.dart';

abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<WalletEntity> wallets;
  
  const WalletLoaded(this.wallets);
}

class WalletError extends WalletState {
  final String message;
  
  const WalletError(this.message);
}