import '../repository/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> execute(int id) async {
    return await repository.deleteTransaction(id);
  }
}