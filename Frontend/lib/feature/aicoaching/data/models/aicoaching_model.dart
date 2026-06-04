import '../../domain/entities/aicoaching_entity.dart';

class AICoachingModel extends AICoachingEntity {
  AICoachingModel({
    required int id,
    required String review,
    required int financialScore,
    required String createdAt,
  }) : super(
          id: id,
          review: review,
          financialScore: financialScore,
          createdAt: createdAt,
        );

  factory AICoachingModel.fromJson(Map<String, dynamic> json) {
    return AICoachingModel(
      id: json['id'] ?? 0,
      review: json['review'] ?? 'Không có nhận xét.',
      financialScore: json['financial_score'] ?? 100, // Mặc định 100% nếu lỗi
      createdAt: json['created_at'] ?? '',
    );
  }
}