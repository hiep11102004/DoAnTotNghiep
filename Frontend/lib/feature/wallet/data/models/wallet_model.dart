import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({
    required String id,
    required String userId,
    required String name,
    required double balance,
    required String currency,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    userId: userId,
    name: name,
    balance: balance,
    currency: currency,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // factory WalletModel.fromJson(Map<String, dynamic> json) {
  //   return WalletModel(
  //     id: json['id'] as String,
  //     userId: json['userId'] as String,
  //     name: json['name'] as String,
  //     balance: (json['currentBalance'] as num).toDouble(),
  //     currency: json['currency'] as String,
  //     createdAt: DateTime.parse(json['createdAt'] as String),
  //     updatedAt: DateTime.parse(json['updatedAt'] as String),
  //   );
  // }
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      // Dùng ?.toString() để đảm bảo nếu null cũng không bị crash
      id: json['id']?.toString() ?? '0',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '1',
      name: json['name']?.toString() ?? 'Ví chưa đặt tên',
      // Ép kiểu cực kỳ an toàn cho số dư
      balance: double.tryParse((json['current_balance'] ?? json['currentBalance'])?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'VND',
      // Dùng tryParse để không bị lỗi nếu ngày tháng từ MySQL trả về rỗng hoặc sai format
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'])?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'])?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'currentBalance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
