import '../../domain/entities/transaction_entity.dart';
import '../../domain/repository/transaction_repository.dart';
import '../datasource/transaction_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    return await datasource.getTransactions();
  }

  @override
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
  }) async {
    final model = TransactionModel(
      id: 0,
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      type: type,
      date: date,
      note: note,
      imageUrl: imageUrl,
      status: status,
      source: source,
    );

    return await datasource.createTransaction(model.toJson());
  }

  @override
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
  }) async {
    final model = TransactionModel(
      id: id,
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      type: type,
      date: date,
      note: note,
      imageUrl: imageUrl,
      status: status,
      source: source,
    );

    return await datasource.updateTransaction(id, model.toJson());
  }

  @override
  Future<void> deleteTransaction(int id) async {
    return await datasource.deleteTransaction(id);
  }
}