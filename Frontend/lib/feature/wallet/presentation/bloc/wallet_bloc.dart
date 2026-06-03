import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';
import '../../data/models/wallet_model.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final Dio dio;

  WalletBloc({required this.dio}) : super(WalletInitial()) {
    
    on<FetchWallets>((event, emit) async {
      emit(WalletLoading());
      try {
        // Gọi API đến máy chủ Laravel qua mạng LAN
        final response = await dio.get('http://192.168.1.140:8000/api/wallets');

        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          
          // Duyệt mảng JSON và dùng hàm từ WalletModel ông đã sửa để bóc tách dữ liệu sạch
          final wallets = data.map((json) => WalletModel.fromJson(json as Map<String, dynamic>)).toList();
          
          // Phát trạng thái Loaded kèm danh sách ví cho UI vẽ giao diện
          emit(WalletLoaded(wallets));
        } else {
          emit(WalletError('Máy chủ phản hồi mã lỗi: ${response.statusCode}'));
        }
      } catch (e) {
        emit(WalletError('Lỗi kết nối hệ thống ví: $e'));
      }
    });
    
  }
}