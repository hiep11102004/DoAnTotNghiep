import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  
  @override
  List<Object?> get props => [];
}

// 1. Trạng thái khởi tạo ban đầu
class TransactionInitial extends TransactionState {}

// 2. Trạng thái đang gọi API (Hiện vòng xoay Loading)
class TransactionLoading extends TransactionState {}

// 3. Trạng thái lấy danh sách giao dịch thành công
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  const TransactionLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

// 4. Trạng thái Thao tác thành công (Dùng chung cho Thêm, Sửa, Xóa thành công)
class TransactionActionSuccess extends TransactionState {
  final String message;

  const TransactionActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// 5. Trạng thái Thất bại (Bị lỗi kết nối, lỗi validate...)
class TransactionFailure extends TransactionState {
  final String message;

  const TransactionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}