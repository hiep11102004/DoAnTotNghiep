import 'package:dio/dio.dart';
import '../models/transaction_model.dart';

class TransactionDatasource {
  final Dio dio;

  TransactionDatasource(this.dio);

  // 1. Lấy danh sách giao dịch
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await dio.get('/transactions');
      
      // 🛠️ THÊM DÒNG NÀY ĐỂ SOI KẾT QUẢ LARAVEL TRẢ VỀ:
      print('🔥 DATA GET ĐƯỢC: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy danh sách giao dịch');
      }
    } on DioException catch (e) {
      // 🛠️ THÊM DÒNG NÀY ĐỂ BẮT LỖI 500/404 NẾU CÓ:
      // print('🔥 LỖI TỪ LARAVEL KHI GET: ${e.response?.data}');
      throw Exception('Lỗi kết nối Server: $e');
    } catch (e) {
      // print('🔥 LỖI FLUTTER KHI PARSE JSON: $e');
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  // 2. Thêm mới giao dịch
  Future<TransactionModel> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await dio.post('/transactions', data: transactionData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return TransactionModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Không thể tạo giao dịch');
      }
    } on DioException catch (e) {
      // 🛠️ THÊM DÒNG PRINT NÀY VÀO ĐỂ ÉP LỖI HIỆN RA:
      // print('🔥 LỖI TỪ LARAVEL TỪ CHỐI GIAO DỊCH: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối Server');
    } catch (e) {
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  // 3. Cập nhật giao dịch
  Future<TransactionModel> updateTransaction(int id, Map<String, dynamic> transactionData) async {
    try {
      final response = await dio.put('/transactions/$id', data: transactionData);
      if (response.statusCode == 200) {
        return TransactionModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Không thể cập nhật giao dịch');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }

  // 4. Xóa giao dịch
  Future<void> deleteTransaction(int id) async {
    try {
      final response = await dio.delete('/transactions/$id');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Không thể xóa giao dịch');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối Server: $e');
    }
  }
}