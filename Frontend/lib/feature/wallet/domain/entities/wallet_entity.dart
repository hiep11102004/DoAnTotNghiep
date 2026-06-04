class WalletEntity {
  final int id;
  final String name;
  final double initialBalance;
  final double currentBalance;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.currentBalance,
  });

  // 🛠️ THỦ THUẬT: Đánh lừa UI. 
  // UI gọi wallet.balance thì nó sẽ tự động lấy currentBalance trả về
  double get balance => currentBalance; 
}