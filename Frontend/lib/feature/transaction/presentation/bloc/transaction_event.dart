import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// 1. Sự kiện yêu cầu tải danh sách giao dịch
class FetchTransactions extends TransactionEvent {}

// 2. Sự kiện thêm mới giao dịch
class AddTransactionSubmitted extends TransactionEvent {
  final int walletId;
  final int categoryId;
  final double amount;
  final String type;
  final String date;
  final String? note;
  final String? imageUrl;
  final String status;
  final String? source;

  const AddTransactionSubmitted({
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.imageUrl,
    required this.status,
    this.source,
  });

  @override
  List<Object?> get props => [walletId, categoryId, amount, type, date, note, imageUrl, status, source];
}

// 3. Sự kiện sửa giao dịch
class UpdateTransactionSubmitted extends TransactionEvent {
  final int id;
  final int walletId;
  final int categoryId;
  final double amount;
  final String type;
  final String date;
  final String? note;
  final String? imageUrl;
  final String status;
  final String? source;

  const UpdateTransactionSubmitted({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.imageUrl,
    required this.status,
    this.source,
  });

  @override
  List<Object?> get props => [id, walletId, categoryId, amount, type, date, note, imageUrl, status, source];
}

// 4. Sự kiện xóa giao dịch
class DeleteTransactionPressed extends TransactionEvent {
  final int id;

  const DeleteTransactionPressed({required this.id});

  @override
  List<Object?> get props => [id];
}