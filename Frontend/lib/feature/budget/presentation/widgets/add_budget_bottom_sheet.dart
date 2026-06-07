import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/category/presentation/bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/core/constants/app_theme.dart';

class AddBudgetBottomSheet extends StatefulWidget {
  const AddBudgetBottomSheet({super.key});

  @override
  State<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends State<AddBudgetBottomSheet> {
  final _limitController = TextEditingController();
  int? _selectedCategoryId;
  String _selectedCategoryName = '';

  // ── Business logic (unchanged) ─────────────────────────────────────────────

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  IconData _getIconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('ăn') || n.contains('uống')) return Icons.restaurant_rounded;
    if (n.contains('di chuyển') || n.contains('xe')) return Icons.directions_car_rounded;
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
    return Icons.label_rounded;
  }

  void _submitData() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng chọn danh mục ngân sách!'),
          behavior: SnackBarBehavior.floating));
      return;
    }
    final limit =
        double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0;
    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Hạn mức phải lớn hơn 0!'),
          behavior: SnackBarBehavior.floating));
      return;
    }

    final now = DateTime.now();
    final startDateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final endDateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}";

    context.read<BudgetBloc>().add(AddBudget(
          categoryId: _selectedCategoryId!,
          amountLimit: limit,
          startDate: startDateStr,
          endDate: endDateStr,
        ));

    Navigator.of(context).pop(true);
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  String get _monthLabel {
    const months = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    final now = DateTime.now();
    return '${months[now.month]}, ${now.year}';
  }

  double get _previewRatio {
    final limit =
        double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0;
    return limit > 0 ? 0.0 : 0.0;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lập ngân sách', style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _monthLabel,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Category section ──
                  Text(
                    'CHỌN DANH MỤC',
                    style: AppTextStyles.label.copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoryGrid(),
                  const SizedBox(height: 20),

                  // ── Amount section ──
                  _buildAmountSection(),
                  const SizedBox(height: 20),

                  // ── Submit ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: AppWidgets.primaryButtonStyle(),
                      child: const Text('Lưu ngân sách',
                          style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, catState) {
        if (catState is CategoryLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        final expenseCategories = catState is CategoryLoaded
            ? catState.categories
                .where((c) => c.type == 'expense')
                .toList()
            : <dynamic>[];

        if (_selectedCategoryId != null &&
            !expenseCategories.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = null;
          _selectedCategoryName = '';
        }

        if (expenseCategories.isEmpty) {
          return Text('Không tải được danh mục',
              style: AppTextStyles.bodySmall);
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: expenseCategories.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategoryId = cat.id;
                _selectedCategoryName = cat.name;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.12)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForCategory(cat.name),
                      size: 14,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAmountSection() {
    final limit =
        double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0;
    final hasPreview = _selectedCategoryId != null && limit > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HẠN MỨC THÁNG',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Text(
                'đ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          if (hasPreview) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$_selectedCategoryName — giới hạn ${_formatCurrency(limit)}/tháng',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') +
        ' đ';
  }
}
