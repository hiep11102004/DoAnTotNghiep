import '../../domain/entities/aicoaching_entity.dart';

class AICoachingModel extends AICoachingEntity {
  AICoachingModel({
    required int id,
    required String review,
    required int financialScore,
    required String createdAt,
    List<String> detectedProblems = const [],
    List<String> recommendations = const [],
  }) : super(
          id: id,
          review: review,
          financialScore: financialScore,
          createdAt: createdAt,
          detectedProblems: detectedProblems,
          recommendations: recommendations,
        );

  factory AICoachingModel.fromJson(Map<String, dynamic> json) {
    List<String> _parseStringList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    return AICoachingModel(
      id: json['id'] ?? 0,
      review: json['review'] ?? 'Không có nhận xét.',
      financialScore: json['financial_score'] ?? 50,
      createdAt: json['created_at'] ?? '',
      detectedProblems: _parseStringList(json['detected_problems']),
      recommendations: _parseStringList(json['recommendations']),
    );
  }
}

class AITaskModel {
  final int id;
  final String title;
  final int exp;
  final bool isCompleted;
  final String? deadline;

  AITaskModel({
    required this.id,
    required this.title,
    required this.exp,
    required this.isCompleted,
    this.deadline,
  });

  factory AITaskModel.fromJson(Map<String, dynamic> json) {
    return AITaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      exp: json['exp'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      deadline: json['deadline']?.toString(),
    );
  }
}

class ChallengeModel {
  final int id;
  final String name;
  final String description;
  final int rewardPoints;
  final String endDate;

  ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rewardPoints,
    required this.endDate,
  });

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

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.xpReward,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'],
      xpReward: json['xp_reward'] ?? 0,
    );
  }
}
