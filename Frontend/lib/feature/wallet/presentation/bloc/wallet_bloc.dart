import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:financial_app/core/constants/app_constants.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../data/models/wallet_model.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final Dio dio;

  WalletBloc({required this.dio}) : super(WalletInitial()) {
    
    on<FetchWallets>((event, emit) async {
      emit(WalletLoading());
      try {
        final response = await dio.get(AppConstants.wallets);
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final wallets = data.map((json) => WalletModel.fromJson(json as Map<String, dynamic>)).toList();
          emit(WalletLoaded(wallets));
        } else {
          emit(WalletError('Lỗi: ${response.statusCode}'));
        }
      } catch (e) {
        emit(WalletError('Lỗi kết nối: ${e.toString()}'));
      }
    });

    on<CreateWallet>((event, emit) async {
      try {
        await dio.post(AppConstants.wallets, data: {
          'name': event.name,
          'initial_balance': event.initialBalance,
          'current_balance': event.initialBalance,
          'type': 'Cash', // Mặc định là Cash nếu ông chưa làm dropdown chọn loại ví
          'currency': 'VND', // Mặc định là VND
        });
        add(const FetchWallets());
      } catch (e) {
        emit(WalletError('Tạo ví thất bại: ${e.toString()}'));
      }
    });
  }
}