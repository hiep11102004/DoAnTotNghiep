import 'package:flutter/material.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../../core/constants/app_theme.dart';

class BudgetCard extends StatelessWidget {
  final BudgetEntity budget;

  const BudgetCard({super.key, required this.budget});

  IconData _getIconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('ăn') || n.contains('uống')) return Icons.restaurant_rounded;
    if (n.contains('di chuyển') || n.contains('xăng') || n.contains('xe')) return Icons.directions_car_rounded;
    if (n.contains('mua sắm')) return Icons.shopping_bag_rounded;
    if (n.contains('giải trí') || n.contains('phim')) return Icons.movie_rounded;
    if (n.contains('hóa đơn') || n.contains('tiện ích')) return Icons.receipt_long_rounded;
    if (n.contains('sức khỏe') || n.contains('y tế')) return Icons.medical_services_rounded;
    if (n.contains('giáo dục') || n.contains('học')) return Icons.school_rounded;
    if (n.contains('tiền nhà') || n.contains('thuê') || n.contains('trọ')) return Icons.home_rounded;
    if (n.contains('du lịch')) return Icons.flight_rounded;
    if (n.contains('quần áo') || n.contains('thời trang')) return Icons.checkroom_rounded;
    if (n.contains('làm đẹp') || n.contains('spa')) return Icons.spa_rounded;
    if (n.contains('gia dụng')) return Icons.chair_rounded;
    if (n.contains('thể thao') || n.contains('gym')) return Icons.fitness_center_rounded;
    if (n.contains('quà')) return Icons.card_giftcard_rounded;
    if (n.contains('tiết kiệm') || n.contains('đầu tư') || n.contains('lãi')) return Icons.savings_rounded;
    if (n.contains('phí ngân hàng')) return Icons.account_balance_rounded;
    if (n.contains('bảo hiểm')) return Icons.security_rounded;
    if (n.contains('lương')) return Icons.payments_rounded;
    if (n.contains('thưởng')) return Icons.emoji_events_rounded;
    if (n.contains('freelance') || n.contains('làm thêm')) return Icons.laptop_rounded;
    if (n.contains('kinh doanh')) return Icons.store_rounded;
    if (n.contains('hoàn tiền') || n.contains('bồi thường')) return Icons.replay_rounded;
    return Icons.pie_chart_rounded;
  }

  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') +
        ' đ';
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = budget.limit > 0
        ? (budget.spent / budget.limit).clamp(0.0, 1.0)
        : 0.0;
    final remaining = budget.limit - budget.spent;
    final isOverBudget = budget.spent > budget.limit;

    Color progressColor;
    Color bgColor;
    if (percentage >= 0.9) {
      progressColor = AppColors.expense;
      bgColor = AppColors.expenseBg;
    } else if (percentage >= 0.7) {
      progressColor = AppColors.warning;
      bgColor = AppColors.warningBg;
    } else {
      progressColor = AppColors.income;
      bgColor = AppColors.incomeBg;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppWidgets.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_getIconForCategory(budget.categoryName), color: progressColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  budget.categoryName.isEmpty ? 'Ngân sách #${budget.categoryId}' : budget.categoryName,
                  style: AppTextStyles.bodyLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Spent / Limit row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đã tiêu', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(budget.spent),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(isOverBudget ? 'Vượt hạn mức' : 'Còn lại', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    isOverBudget ? '+${_formatCurrency(-remaining)}' : _formatCurrency(remaining),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isOverBudget ? AppColors.expense : AppColors.income,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Hạn mức dòng nhỏ bên dưới
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Hạn mức tháng: ${_formatCurrency(budget.limit)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
