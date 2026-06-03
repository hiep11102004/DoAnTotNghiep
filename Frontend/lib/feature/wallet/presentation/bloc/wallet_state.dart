import '../../domain/entities/wallet_entity.dart';

abstract class WalletState {
  const WalletState();
}

// Trạng thái khởi tạo ban đầu
class WalletInitial extends WalletState {
  const WalletInitial();
}

// Trạng thái đang đợi API phản hồi (Xoay vòng vòng loading)
class WalletLoading extends WalletState {
  const WalletLoading();
}

// Trạng thái đã lấy được dữ liệu thành công và truyền danh sách Entity ra UI
class WalletLoaded extends WalletState {
  final List<WalletEntity> wallets;

  const WalletLoaded(this.wallets);
}

// Trạng thái xảy ra lỗi (Lỗi mạng, lỗi server 500,...)
class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);
}