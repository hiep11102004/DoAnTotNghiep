import 'package:flutter/material.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetCard extends StatelessWidget {
  final BudgetEntity budget;

  const BudgetCard({super.key, required this.budget});

  // 🛠️ TỪ ĐIỂN DỊCH ID THÀNH TÊN DANH MỤC NGÂN SÁCH KÈM EMOJI
  String _getCategoryName(dynamic id) {
    final int categoryId = int.tryParse(id.toString()) ?? 0;
    
    switch (categoryId) {
      case 1: return 'Ăn uống 🍔';
      case 2: return 'Đi lại 🚗'; 
      case 3: return 'Mua sắm 🛍️';
      case 4: return 'Giải trí 🎬';
      case 5: return 'Hóa đơn 🧾';
      case 6: return 'Sức khỏe 💊';
      default: return 'Ngân sách #$categoryId';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic tính toán: tỉ lệ đã tiêu
    double percentage = budget.limit > 0 ? (budget.spent / budget.limit) : 0;
    if (percentage > 1.0) percentage = 1.0; // Không vượt quá 100% thanh bar

    // Logic đổi màu: Xanh (dưới 80%) -> Vàng (80-90%) -> Đỏ (>90%)
    Color progressColor = Colors.green.shade600;
    if (percentage >= 0.9) {
      progressColor = Colors.red.shade600;
    } else if (percentage >= 0.8) {
      progressColor = Colors.orange.shade600;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🛠️ ĐÃ THAY BẰNG HÀM DỊCH TÊN
              Text(
                _getCategoryName(budget.categoryId), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50))
              ), 
              Text('${(percentage * 100).toInt()}%', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã tiêu: ${budget.spent.toInt()}đ', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('Hạn mức: ${budget.limit.toInt()}đ', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}