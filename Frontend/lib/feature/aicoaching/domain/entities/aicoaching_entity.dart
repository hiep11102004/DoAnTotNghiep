class AICoachingEntity {
  final int id;
  final String review;
  final int financialScore; // Điểm số tài chính (Ví dụ: 85%)
  final String createdAt;

  AICoachingEntity({
    required this.id,
    required this.review,
    required this.financialScore,
    required this.createdAt,
  });
}