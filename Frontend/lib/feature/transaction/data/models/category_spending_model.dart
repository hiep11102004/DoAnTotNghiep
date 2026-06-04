class CategorySpendingModel {
  final String categoryName;
  final double totalAmount;
  final String colorHex; 

  CategorySpendingModel({
    required this.categoryName,
    required this.totalAmount,
    required this.colorHex,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) {
    // Lấy object 'category' từ JSON. 
    // Nếu giao dịch nào bị mồ côi (không có category), nó sẽ gán là một Map rỗng {} để không bị crash app.
    final Map<String, dynamic> category = json['category'] ?? {};

    return CategorySpendingModel(
      // Lấy tên danh mục. Dùng .toString() cho chắc cốp, rỗng thì để 'Chưa phân loại'
      categoryName: category['name']?.toString() ?? 'Chưa phân loại',
      
      // Lấy tổng tiền (total_amount từ hàm SUM của Laravel). Ép kiểu an toàn qua double.
      totalAmount: (double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0).abs(),
      
      // Lấy mã màu (icon_color). Nếu trong database ông chưa nhập màu, nó sẽ lấy màu xám mặc định (#95A5A6)
      colorHex: category['icon_color']?.toString() ?? '#95A5A6',
    );
  }
}