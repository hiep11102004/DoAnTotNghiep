class WalletEntity {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
}
