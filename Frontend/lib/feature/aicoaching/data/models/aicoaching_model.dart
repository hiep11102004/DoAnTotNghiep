import '../../domain/entities/aicoaching_entity.dart';

class AICoachingModel extends AICoachingEntity {
  AICoachingModel({
    required int id,
    required String review,
    required int financialScore,
    required String createdAt,
  }) : super(id: id, review: review, financialScore: financialScore, createdAt: createdAt);

  factory AICoachingModel.fromJson(Map<String, dynamic> json) {
    return AICoachingModel(
      id: json['id'] ?? 0,
      review: json['review'] ?? 'Không có nhận xét.',
      financialScore: json['financial_score'] ?? 100, // Mặc định 100% nếu lỗi
      createdAt: json['created_at'] ?? '',
    );
  }
}

class AITaskModel {
  final int id;
  final String title;
  final int exp;
  final bool isCompleted;

  AITaskModel({required this.id, required this.title, required this.exp, required this.isCompleted});

  factory AITaskModel.fromJson(Map<String, dynamic> json) {
    return AITaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      exp: json['exp'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class ChallengeModel {
  final int id;
  final String name;
  final String description;
  final int rewardPoints;
  final String endDate;

  ChallengeModel({required this.id, required this.name, required this.description, required this.rewardPoints, required this.endDate});

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      rewardPoints: json['reward_points'] ?? 0,
      endDate: json['end_date'] ?? '',
    );
  }
}

class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String? iconUrl;
  final int xpReward;

  BadgeModel({required this.id, required this.name, required this.description, this.iconUrl, required this.xpReward});

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id:          json['id'] ?? 0,
      name:        json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl:     json['icon_url'],
      xpReward:    json['xp_reward'] ?? 0,
    );
  }
}