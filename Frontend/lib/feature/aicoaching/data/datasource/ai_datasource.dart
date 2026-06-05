import 'package:dio/dio.dart';
import '../models/aicoaching_model.dart';
import 'aicoaching_datasource.dart';

class AIDatasource implements AICoachingDataSource {
  final Dio dio;
  AIDatasource(this.dio);

  @override
  Future<AICoachingModel> getCoachings() async {
    try {
      // Gemini API mất 15-40s → cần timeout riêng, không dùng default 10s
      final response = await dio.get(
        '/ai/reviews',
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      if (response.statusCode == 200) {
        return AICoachingModel.fromJson(response.data['data']);
      }
      throw Exception('Server trả về lỗi');
    } catch (e) {
      throw Exception('Lỗi kết nối Trợ lý AI: $e');
    }
  }

  Future<List<AITaskModel>> getTasks() async {
    try {
      final response = await dio.get('/ai/tasks');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => AITaskModel.fromJson(e)).toList();
      }
      throw Exception('Không thể tải nhiệm vụ');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<void> completeTask(int id) async {
    try {
      await dio.post('/ai/tasks/$id/complete');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi hoàn thành nhiệm vụ');
    }
  }

  Future<List<ChallengeModel>> getChallenges() async {
    try {
      final response = await dio.get('/challenges');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((e) => ChallengeModel.fromJson(e)).toList();
      }
      throw Exception('Không thể tải thử thách');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
    }
  }

  Future<void> joinChallenge(int id) async {
    try {
      await dio.post('/challenges/$id/join');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tham gia thử thách');
    }
  }

  Future<List<BadgeModel>> getBadges() async {
    try {
      final response = await dio.get('/badges');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        return data.map((e) => BadgeModel.fromJson(e)).toList();
      }
      throw Exception('Không thể tải huy hiệu');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối');
    }
  }

  @override
  Future<AICoachingModel> getCoachingById(String id) async => throw UnimplementedError();
  @override
  Future<AICoachingModel> createCoaching(AICoachingModel coaching) async => throw UnimplementedError();
  @override
  Future<AICoachingModel> updateCoaching(AICoachingModel coaching) async => throw UnimplementedError();
  @override
  Future<void> deleteCoaching(String id) async => throw UnimplementedError();
}