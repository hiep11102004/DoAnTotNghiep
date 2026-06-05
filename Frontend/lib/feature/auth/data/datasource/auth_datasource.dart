import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';

class AuthDatasource {
  final Dio dio;

  AuthDatasource(this.dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        AppConstants.login,
        data: {'username': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối Server');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await dio.post(
        AppConstants.register,
        data: {'full_name': name, 'username': email.split('@')[0], 'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi đăng ký thất bại');
    }
  }

  Future<void> logout() async {
    try {
      await dio.post(AppConstants.logout);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi đăng xuất');
    }
  }
}