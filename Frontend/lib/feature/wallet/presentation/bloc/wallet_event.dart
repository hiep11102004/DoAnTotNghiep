abstract class WalletEvent {
  const WalletEvent();
}

// Sự kiện gọi API lấy danh sách ví
class FetchWallets extends WalletEvent {
  const FetchWallets();
}