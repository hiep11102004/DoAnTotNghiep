import 'package:dio/dio.dart';
import 'package:financial_app/core/constants/app_constants.dart';
import 'package:financial_app/feature/wallet/domain/repository/wallet_repository.dart';

import '../../domain/entities/wallet_entity.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final Dio dio;

  // Tiêm (Inject) Dio vào để dùng
  WalletRepositoryImpl({required this.dio});

  @override
  Future<List<WalletEntity>> getWallets() async {
    try {
      final response = await dio.get(AppConstants.wallets);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WalletModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Mã lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi mạng hoặc API: ${e.toString()}');
    }
  }

  @override
  Future<void> createWallet({
    required String name, 
    required double initialBalance, 
    required double currentBalance
  }) async {
    try {
      final response = await dio.post(AppConstants.wallets, data: {
        'name': name,
        'initial_balance': initialBalance,
        'current_balance': currentBalance,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Mã lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi mạng hoặc API: ${e.toString()}');
    }
  }
  
  // ==========================================
  // CÁC HÀM NÀY TẠM THỜI ĐỂ RỖNG, ANH EM MÌNH SẼ LÀM CHỨC NĂNG SỬA/XÓA SAU
  // ==========================================

  @override
  Future<WalletEntity> getWalletById(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<WalletEntity> updateWallet(WalletEntity wallet) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWallet(int id) async {
    throw UnimplementedError();
  }
}