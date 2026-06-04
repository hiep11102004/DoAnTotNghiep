import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.name,
    required super.initialBalance,
    required super.currentBalance,
  });

  // 🛠️ Parse chuẩn 2 trường từ Laravel trả về
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? 'Ví chưa đặt tên',
      initialBalance: double.tryParse(json['initial_balance']?.toString() ?? '0') ?? 0.0,
      currentBalance: double.tryParse(json['current_balance']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
    };
  }
}