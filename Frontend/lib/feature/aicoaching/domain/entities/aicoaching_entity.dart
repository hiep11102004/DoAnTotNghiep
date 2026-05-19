class AICoachingEntity {
  final String id;
  final String userId;
  final String topic;
  final String description;
  final String content;
  final List<String> tips;
  final DateTime createdAt;
  final DateTime updatedAt;

  AICoachingEntity({
    required this.id,
    required this.userId,
    required this.topic,
    required this.description,
    required this.content,
    required this.tips,
    required this.createdAt,
    required this.updatedAt,
  });
}
