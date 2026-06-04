import 'package:dio/dio.dart';
import '../models/aicoaching_model.dart';
import 'aicoaching_datasource.dart'; // 👈 Import cái file bản thiết kế của ông vào

// Giữ nguyên tên class cũ AIDatasource của ông, chỉ thêm phần "implements" ở đuôi
class AIDatasource implements AICoachingDataSource {
  final Dio dio;
  AIDatasource(this.dio);

  @override
  Future<AICoachingModel> getCoachings() async {
    try {
      final response = await dio.get('/ai/reviews');
      if (response.statusCode == 200) {
        return AICoachingModel.fromJson(response.data['data']);
      }
      throw Exception('Server trả về lỗi');
    } catch (e) {
      throw Exception('Lỗi kết nối Trợ lý AI: $e');
    }
  }

  // 🛠️ VÌ ĐÃ "IMPLEMENTS" NÊN ÔNG PHẢI LÔI MẤY HÀM TRỐNG NÀY VÀO CHO ĐỦ BỘ,
  // Cứ để trống (UnimplementedError) như này code sẽ không bị gạch đỏ nữa.
  @override
  Future<AICoachingModel> getCoachingById(String id) async => throw UnimplementedError();
  @override
  Future<AICoachingModel> createCoaching(AICoachingModel coaching) async => throw UnimplementedError();
  @override
  Future<AICoachingModel> updateCoaching(AICoachingModel coaching) async => throw UnimplementedError();
  @override
  Future<void> deleteCoaching(String id) async => throw UnimplementedError();
}