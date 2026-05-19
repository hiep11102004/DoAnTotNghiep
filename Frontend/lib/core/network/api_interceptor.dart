import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Nếu đã đăng nhập và có token, tự động gắn vào Header Bearer
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Bắt buộc Laravel hiểu đây là request API để trả về JSON khi có lỗi
    options.headers['Accept'] = 'application/json';

    return super.onRequest(options, handler);
  }
}