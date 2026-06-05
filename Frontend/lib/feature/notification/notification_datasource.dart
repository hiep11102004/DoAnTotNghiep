import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotificationDatasource {
  final Dio dio;
  NotificationDatasource(this.dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get(AppConstants.notifications);
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tải thông báo');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await dio.put('${AppConstants.notifications}/$id/read');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi đánh dấu đã đọc');
    }
  }
}
