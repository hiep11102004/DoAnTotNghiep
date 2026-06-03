import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();

  Future<TransactionEntity> createTransaction({
    required int walletId,
    required int categoryId,
    required double amount,
    required String type,
    required String date,
    String? note,
    String? imageUrl,
    required String status,
    String? source,
  });

  Future<TransactionEntity> updateTransaction({
    required int id,
    required int walletId,
    required int categoryId,
    required double amount,
    required String type,
    required String date,
    String? note,
    String? imageUrl,
    required String status,
    String? source,
  });

  Future<void> deleteTransaction(int id);
}