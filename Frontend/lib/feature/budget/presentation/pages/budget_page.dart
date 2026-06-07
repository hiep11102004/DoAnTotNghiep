import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_card.dart';
import '../widgets/add_budget_bottom_sheet.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../feature/category/presentation/bloc/category_bloc.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(FetchBudgets());
  }

  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') +
        ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(
        title: 'Ngân sách',
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is BudgetError) {
            return AppWidgets.emptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Không thể tải ngân sách',
              subtitle: state.message,
              action: ElevatedButton.icon(
                onPressed: () => context.read<BudgetBloc>().add(FetchBudgets()),
                style: AppWidgets.primaryButtonStyle(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại', style: AppTextStyles.buttonSmall),
              ),
            );
          }

          if (state is BudgetLoaded) {
            if (state.budgets.isEmpty) {
              return AppWidgets.emptyState(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Chưa có ngân sách',
                subtitle: 'Thiết lập ngân sách tháng để kiểm soát chi tiêu hiệu quả hơn',
              );
            }

            // Tính tổng hạn mức và đã tiêu
            final totalLimit = state.budgets.fold<double>(0, (s, b) => s + b.limit);
            final totalSpent = state.budgets.fold<double>(0, (s, b) => s + b.spent);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<BudgetBloc>().add(FetchBudgets()),
              child: Column(
                children: [
                  _buildSummaryCard(totalSpent, totalLimit),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, 100),
                      itemCount: state.budgets.length,
                      itemBuilder: (context, index) =>
                          BudgetCard(budget: state.budgets[index]),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<BudgetBloc>()),
                BlocProvider.value(value: context.read<CategoryBloc>()),
              ],
              child: const AddBudgetBottomSheet(),
            ),
          );
          if (result == true && context.mounted) {
            context.read<BudgetBloc>().add(FetchBudgets());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ngân sách', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCard(double totalSpent, double totalLimit) {
    final ratio = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final remaining = totalLimit - totalSpent;

    Color statusColor;
    String statusLabel;
    if (ratio >= 0.9) {
      statusColor = AppColors.expense;
      statusLabel = 'Gần hết hạn mức';
    } else if (ratio >= 0.7) {
      statusColor = AppColors.warning;
      statusLabel = 'Cần chú ý';
    } else {
      statusColor = AppColors.income;
      statusLabel = 'Trong ngưỡng an toàn';
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppWidgets.cardDecoration(radius: AppRadius.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tháng này', style: AppTextStyles.label),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(statusLabel, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(totalSpent),
                style: AppTextStyles.amountLarge.copyWith(color: statusColor),
              ),
              Text(
                ' / ${_formatCurrency(totalLimit)}',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã dùng ${(ratio * 100).toInt()}%',
                style: AppTextStyles.caption,
              ),
              Text(
                remaining >= 0
                    ? 'Còn lại: ${_formatCurrency(remaining)}'
                    : 'Vượt: ${_formatCurrency(-remaining)}',
                style: AppTextStyles.caption.copyWith(
                  color: remaining >= 0 ? AppColors.income : AppColors.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
