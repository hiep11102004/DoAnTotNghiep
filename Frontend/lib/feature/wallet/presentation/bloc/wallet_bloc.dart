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
          'type': 'Cash',
          'currency': 'VND',
        });
        add(const FetchWallets());
      } catch (e) {
        emit(WalletError('Tạo ví thất bại: ${e.toString()}'));
      }
    });

    on<UpdateWallet>((event, emit) async {
      final previous = state is WalletLoaded
          ? (state as WalletLoaded).wallets
          : state is WalletActionFailure
              ? (state as WalletActionFailure).wallets
              : null;
      try {
        await dio.put('${AppConstants.wallets}/${event.id}', data: {
          'name': event.name,
        });
        add(const FetchWallets());
      } on DioException catch (e) {
        final msg =
            e.response?.data['message']?.toString() ?? 'Cập nhật ví thất bại';
        if (previous != null) {
          emit(WalletActionFailure(msg, previous));
        } else {
          emit(WalletError(msg));
        }
      } catch (e) {
        final msg = 'Cập nhật ví thất bại: ${e.toString()}';
        if (previous != null) {
          emit(WalletActionFailure(msg, previous));
        } else {
          emit(WalletError(msg));
        }
      }
    });

    on<DeleteWallet>((event, emit) async {
      final previous = state is WalletLoaded
          ? (state as WalletLoaded).wallets
          : state is WalletActionFailure
              ? (state as WalletActionFailure).wallets
              : null;
      try {
        await dio.delete('${AppConstants.wallets}/${event.id}');
        add(const FetchWallets());
      } on DioException catch (e) {
        final msg = e.response?.data['message']?.toString() ?? 'Xóa ví thất bại';
        if (previous != null) {
          emit(WalletActionFailure(msg, previous));
        } else {
          emit(WalletError(msg));
        }
      } catch (e) {
        final msg = 'Xóa ví thất bại: ${e.toString()}';
        if (previous != null) {
          emit(WalletActionFailure(msg, previous));
        } else {
          emit(WalletError(msg));
        }
      }
    });
  }
}