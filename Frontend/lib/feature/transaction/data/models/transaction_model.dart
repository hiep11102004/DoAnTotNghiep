import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.walletId,
    required super.categoryId,
    required super.amount,
    required super.type, // Thêm lại type vào đây
    required super.date,
    super.note,
    super.imageUrl,
    required super.status,
    super.source,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] ?? 'Chi', // Nhận diện Thu hoặc Chi từ Laravel
      date: json['date'] ?? '',
      note: json['note'],
      imageUrl: json['image_url'],
      status: json['status'] ?? 'Hoàn thành',
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'category_id': categoryId,
      'amount': amount,
      'type': type, // Bắn type lên Laravel để thỏa mãn validate 'required'
      'date': date,
      'note': note,
      'image_url': imageUrl,
      'status': status,
      'source': source,
    };
  }
}