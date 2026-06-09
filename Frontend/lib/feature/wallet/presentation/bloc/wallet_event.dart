abstract class WalletEvent {
  const WalletEvent();
}

class FetchWallets extends WalletEvent {
  const FetchWallets();
}

class CreateWallet extends WalletEvent {
  final String name;
  final double initialBalance;

  const CreateWallet({required this.name, required this.initialBalance});
}

class UpdateWallet extends WalletEvent {
  final int id;
  final String name;

  const UpdateWallet({required this.id, required this.name});
}

class DeleteWallet extends WalletEvent {
  final int id;

  const DeleteWallet({required this.id});
}