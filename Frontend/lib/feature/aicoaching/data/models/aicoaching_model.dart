import '../../domain/entities/aicoaching_entity.dart';

class AICoachingModel extends AICoachingEntity {
  AICoachingModel({
    required String id,
    required String userId,
    required String topic,
    required String description,
    required String content,
    required List<String> tips,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    userId: userId,
    topic: topic,
    description: description,
    content: content,
    tips: tips,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory AICoachingModel.fromJson(Map<String, dynamic> json) {
    return AICoachingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      topic: json['topic'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      tips: List<String>.from(json['tips'] as List<dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'topic': topic,
      'description': description,
      'content': content,
      'tips': tips,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
