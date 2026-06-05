import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';

class SavingGoalModel {
  final int id;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final String? deadline;
  final String status;

  SavingGoalModel({
    required this.id,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.status,
  });

  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingGoalModel(
      id: json['id'] ?? 0,
      goalName: json['goal_name'] ?? '',
      targetAmount: double.tryParse(json['target_amount'].toString()) ?? 0.0,
      currentAmount: double.tryParse(json['current_amount'].toString()) ?? 0.0,
      deadline: json['deadline'],
      status: json['status'] ?? 'Đang thực hiện',
    );
  }
}

class SavingGoalDatasource {
  final Dio dio;
  SavingGoalDatasource(this.dio);

  Future<List<SavingGoalModel>> getGoals() async {
    try {
      final response = await dio.get(AppConstants.savingGoals);
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((e) => SavingGoalModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tải mục tiêu tiết kiệm');
    }
  }

  Future<SavingGoalModel> createGoal(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(AppConstants.savingGoals, data: data);
      return SavingGoalModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể tạo mục tiêu');
    }
  }

  Future<SavingGoalModel> updateGoal(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('${AppConstants.savingGoals}/$id', data: data);
      return SavingGoalModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể cập nhật mục tiêu');
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await dio.delete('${AppConstants.savingGoals}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Không thể xóa mục tiêu');
    }
  }
}
