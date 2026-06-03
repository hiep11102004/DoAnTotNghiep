import '../entities/transaction_entity.dart';
import '../repository/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<TransactionEntity> execute({
    required int walletId,
    required int categoryId,
    required double amount,
    required String date,
    String? note,
    String? imageUrl,
    required String status,
    String? source,
    required String type,
  }) async {
    return await repository.createTransaction(
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      note: note,
      imageUrl: imageUrl,
      status: status,
      source: source,
      type: type,
    );
  }
}