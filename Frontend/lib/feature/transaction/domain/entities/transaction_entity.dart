class TransactionEntity {
  final int id;
  final int walletId;
  final int categoryId;
  final double amount;
  final String date;
  final String? note;
  final String? imageUrl;
  final String status;
  final String? source;
  final String? type;

  const TransactionEntity({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    this.imageUrl,
    required this.status,
    this.source,
    this.type,
  });
}