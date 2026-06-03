import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../domain/usecase/get_transactions_usecase.dart';
import '../../domain/usecase/create_transaction_usecase.dart';
import '../../domain/usecase/update_transaction_usecase.dart';
import '../../domain/usecase/delete_transaction_usecase.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial()) {

    // 1. Xử lý lấy danh sách
    on<FetchTransactions>((event, emit) async {
      emit(TransactionLoading());
      try {
        final transactions = await getTransactionsUseCase.execute();
        emit(TransactionLoaded(transactions: transactions));
      } catch (e) {
        emit(TransactionFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 2. Xử lý thêm mới
    on<AddTransactionSubmitted>((event, emit) async {
      emit(TransactionLoading());
      try {
        await createTransactionUseCase.execute(
          walletId: event.walletId,
          categoryId: event.categoryId,
          amount: event.amount,
          type: event.type,
          date: event.date,
          note: event.note,
          imageUrl: event.imageUrl,
          status: event.status,
          source: event.source,
        );
        emit(const TransactionActionSuccess(message: 'Thêm giao dịch thành công! 🎉'));
        add(FetchTransactions());
      } catch (e) {
        emit(TransactionFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 3. Xử lý cập nhật (Sửa)
    on<UpdateTransactionSubmitted>((event, emit) async {
      emit(TransactionLoading());
      try {
        await updateTransactionUseCase.execute(
          id: event.id,
          walletId: event.walletId,
          categoryId: event.categoryId,
          amount: event.amount,
          type: event.type,
          date: event.date,
          note: event.note,
          imageUrl: event.imageUrl,
          status: event.status,
          source: event.source,
        );
        emit(const TransactionActionSuccess(message: 'Cập nhật giao dịch thành công! ✏️'));
        add(FetchTransactions());
      } catch (e) {
        emit(TransactionFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    // 4. Xử lý Xóa
    on<DeleteTransactionPressed>((event, emit) async {
      emit(TransactionLoading());
      try {
        await deleteTransactionUseCase.execute(event.id);
        emit(const TransactionActionSuccess(message: 'Xóa giao dịch thành công! 🗑️'));
      } catch (e) {
        emit(TransactionFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}