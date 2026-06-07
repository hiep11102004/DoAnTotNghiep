import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/core/constants/app_theme.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../widgets/edit_transaction_bottom_sheet.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  String _filter = 'all'; // all | Thu | Chi

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchTransactions());
  }

  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') +
        ' đ';
  }

  List<TransactionEntity> _applyFilter(List<TransactionEntity> all) {
    if (_filter == 'Thu') return all.where((t) => t.type == 'Thu').toList();
    if (_filter == 'Chi') return all.where((t) => t.type == 'Chi').toList();
    return all;
  }

  // ── Date grouping ──────────────────────────────────────────────────────────
  String _dateHeaderLabel(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Hôm nay';
      if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) return 'Hôm qua';
      const wd = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
      return '${wd[date.weekday]}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  // Returns flat list: [String=dateHeader, TransactionEntity, TransactionEntity, String, ...]
  List<dynamic> _buildGroupedItems(List<TransactionEntity> transactions) {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final items = <dynamic>[];
    String? lastDate;
    for (final t in sorted) {
      final date = t.date.split(' ')[0];
      if (date != lastDate) {
        items.add(date);
        lastDate = date;
      }
      items.add(t);
    }
    return items;
  }

  // ── Summary stats (income/expense totals for filtered view) ───────────────
  Map<String, double> _calcSummary(List<TransactionEntity> transactions) {
    double income = 0, expense = 0;
    for (final t in transactions) {
      if (t.type == 'Thu') income += t.amount;
      else expense += t.amount;
    }
    return {'income': income, 'expense': expense};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppWidgets.appBar(title: 'Tất cả giao dịch'),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionBottomSheet(),
          );
          if (result == true && context.mounted) {
            context.read<TransactionBloc>().add(FetchTransactions());
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _filterChip('all', 'Tất cả'),
          const SizedBox(width: AppSpacing.sm),
          _filterChip('Thu', 'Thu nhập'),
          const SizedBox(width: AppSpacing.sm),
          _filterChip('Chi', 'Chi tiêu'),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm - 1),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is TransactionFailure) {
          return AppWidgets.emptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Không thể tải giao dịch',
            subtitle: state.message,
            action: ElevatedButton.icon(
              onPressed: () => context.read<TransactionBloc>().add(FetchTransactions()),
              style: AppWidgets.primaryButtonStyle(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại', style: AppTextStyles.buttonSmall),
            ),
          );
        }

        if (state is TransactionLoaded) {
          final filtered = _applyFilter(state.transactions);

          if (filtered.isEmpty) {
            return AppWidgets.emptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Không có giao dịch',
              subtitle: _filter == 'all'
                  ? 'Chưa có giao dịch nào. Nhấn + để thêm mới.'
                  : 'Không có giao dịch loại "${_filter == "Thu" ? "Thu nhập" : "Chi tiêu"}".',
            );
          }

          final summary = _calcSummary(filtered);
          final grouped = _buildGroupedItems(filtered);

          return Column(
            children: [
              // Summary bar
              _buildSummaryBar(summary['income']!, summary['expense']!, filtered.length),
              // Grouped list
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context.read<TransactionBloc>().add(FetchTransactions()),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 80),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final item = grouped[index];
                      if (item is String) return _buildDateSeparator(item);
                      if (item is TransactionEntity) return _buildTransactionTile(item);
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSummaryBar(double income, double expense, int count) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _summaryCell(
              label: 'Thu nhập',
              amount: income,
              color: AppColors.income,
              icon: Icons.arrow_downward_rounded,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Expanded(
            child: _summaryCell(
              label: 'Chi tiêu',
              amount: expense,
              color: AppColors.expense,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Expanded(
            child: Column(
              children: [
                Text('$count', style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
                Text('giao dịch', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCell({required String label, required double amount, required Color color, required IconData icon}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') + ' đ',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDateSeparator(String dateStr) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _dateHeaderLabel(dateStr),
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Divider(height: 1, color: AppColors.divider)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(TransactionEntity item) {
    final isIncome = item.type == 'Thu';

    return Dismissible(
      key: Key('tl_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.85),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: const Text('Xóa giao dịch', style: AppTextStyles.h4),
            content: const Text('Bạn có chắc muốn xóa giao dịch này?', style: AppTextStyles.body),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Xóa', style: TextStyle(color: AppColors.expense)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        context.read<TransactionBloc>().add(DeleteTransactionPressed(id: item.id));
      },
      child: GestureDetector(
        onTap: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => EditTransactionBottomSheet(transaction: item),
          );
          if (result == true && context.mounted) {
            context.read<TransactionBloc>().add(FetchTransactions());
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: AppWidgets.cardDecoration(radius: AppRadius.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome ? AppColors.incomeBg : AppColors.expenseBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isIncome ? AppColors.income : AppColors.expense,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.note ?? 'Không có ghi chú',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(item.date.split(' ')[0], style: AppTextStyles.caption),
                  ],
                ),
              ),
              Text(
                '${isIncome ? "+" : "-"}${_formatCurrency(item.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
