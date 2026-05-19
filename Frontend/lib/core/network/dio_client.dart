import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio() {
    dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5), // Quá 5s không kết nối -> Báo lỗi
      receiveTimeout: const Duration(seconds: 5),
    );

    // Thêm bộ lọc Interceptor đã viết ở File 3 vào Dio
    dio.interceptors.add(ApiInterceptor());
    
    // Nếu muốn hiển thị log API chạy dưới terminal để debug thì thêm dòng này:
    // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}