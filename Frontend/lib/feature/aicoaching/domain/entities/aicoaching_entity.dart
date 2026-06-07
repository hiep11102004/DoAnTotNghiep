class AICoachingEntity {
  final int id;
  final String review;
  final int financialScore;
  final String createdAt;
  final List<String> detectedProblems;
  final List<String> recommendations;

  AICoachingEntity({
    required this.id,
    required this.review,
    required this.financialScore,
    required this.createdAt,
    this.detectedProblems = const [],
    this.recommendations = const [],
  });
}
