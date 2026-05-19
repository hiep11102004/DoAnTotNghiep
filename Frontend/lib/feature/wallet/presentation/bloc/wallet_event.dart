part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class GetWalletsEvent extends WalletEvent {
  const GetWalletsEvent();
}

class CreateWalletEvent extends WalletEvent {
  final WalletEntity wallet;

  const CreateWalletEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class UpdateWalletEvent extends WalletEvent {
  final WalletEntity wallet;

  const UpdateWalletEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class DeleteWalletEvent extends WalletEvent {
  final String walletId;

  const DeleteWalletEvent(this.walletId);

  @override
  List<Object?> get props => [walletId];
}
