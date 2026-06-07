import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_app/core/constants/app_theme.dart';

import '../bloc/report_bloc.dart';
import '../../data/models/category_spending_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int touchedIndex = -1;

  // Assign colors semantically: income = green family, expense = warm/cool
  // Uses name-based hashing so the same category always gets the same color
  static const List<Color> _incomeColors = [
    Color(0xFF27AE60), Color(0xFF1ABC9C), Color(0xFF16A085), Color(0xFF2ECC71),
  ];
  static const List<Color> _expenseColors = [
    Color(0xFFE74C3C), Color(0xFF3498DB), Color(0xFFF39C12),
    Color(0xFF9B59B6), Color(0xFFE67E22), Color(0xFF2980B9),
    Color(0xFF8E44AD), Color(0xFFD35400), Color(0xFFC0392B),
    Color(0xFF1F618D), Color(0xFF7D3C98), Color(0xFF873600),
  ];

  Color _colorForCategory(String name) {
    final n = name.toLowerCase();
    final isIncome = n.contains('lương') || n.contains('thưởng') ||
        n.contains('làm thêm') || n.contains('freelance') ||
        n.contains('kinh doanh') || n.contains('đầu tư') || n.contains('lãi') ||
        n.contains('thu nhập') || n.contains('hoàn tiền') ||
        n.contains('được tặng') || n.contains('quà nhận');
    final palette = isIncome ? _incomeColors : _expenseColors;
    // Deterministic pick by summing code units (same name → same color always)
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') +
        ' đ';
  }

  String _formatCurrencyShort(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}tr';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}k';
    return amount.toStringAsFixed(0);
  }

  String get _monthLabel {
    final now = DateTime.now();
    const months = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${months[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is ReportError) {
            return AppWidgets.emptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Không thể tải báo cáo',
              subtitle: state.message,
            );
          }

          if (state is ReportLoaded) {
            final list = state.spendingList;

            if (list.isEmpty) {
              return _buildEmptyBody();
            }

            final total =
                list.fold<double>(0, (s, item) => s + item.totalAmount);

            return CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(child: _buildHeader(total)),
                // ── Donut chart ──
                SliverToBoxAdapter(child: _buildChart(list, total)),
                // ── Legend ──
                SliverToBoxAdapter(
                    child: _buildLegendHeader(list.length)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildLegendItem(list, index, total),
                    childCount: list.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyBody() {
    return Column(
      children: [
        _buildHeader(0),
        Expanded(
          child: AppWidgets.emptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Chưa có dữ liệu',
            subtitle: 'Chưa có chi tiêu nào trong tháng này.',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Báo cáo chi tiêu', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.expenseBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _monthLabel,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.expense),
                ),
              ),
            ],
          ),
          if (total > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('TỔNG CHI',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  _formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChart(List<CategorySpendingModel> list, double total) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 270,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 72,
                sections: _buildSections(list, total),
              ),
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (touchedIndex >= 0 && touchedIndex < list.length) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorForCategory(list[touchedIndex].categoryName).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    list[touchedIndex].categoryName,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _colorForCategory(list[touchedIndex].categoryName)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrencyShort(list[touchedIndex].totalAmount),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _colorForCategory(list[touchedIndex].categoryName)),
                ),
                Text(
                  '${(list[touchedIndex].totalAmount / total * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ] else ...[
                const Text('CHI TIÊU',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  _formatCurrencyShort(total),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary),
                ),
                const Text('tháng này',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
      List<CategorySpendingModel> list, double total) {
    return List.generate(list.length, (i) {
      final isTouched = i == touchedIndex;
      final color = _colorForCategory(list[i].categoryName);
      final pct = total > 0 ? list[i].totalAmount / total * 100 : 0.0;

      return PieChartSectionData(
        color: color,
        value: list[i].totalAmount,
        title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
        radius: isTouched ? 56.0 : 46.0,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black38, blurRadius: 3)],
        ),
        borderSide: isTouched
            ? BorderSide(color: color.withOpacity(0.5), width: 3)
            : BorderSide.none,
      );
    });
  }

  Widget _buildLegendHeader(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text('$count danh mục chi tiêu', style: AppTextStyles.h4),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      List<CategorySpendingModel> list, int index, double total) {
    final item = list[index];
    final color = _colorForCategory(list[index].categoryName);
    final pct = total > 0 ? item.totalAmount / total : 0.0;
    final pctStr = (pct * 100).toStringAsFixed(1);
    final isTouched = index == touchedIndex;

    return GestureDetector(
      onTap: () => setState(() {
        touchedIndex = isTouched ? -1 : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isTouched ? color.withOpacity(0.07) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isTouched ? color.withOpacity(0.4) : AppColors.border,
            width: isTouched ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Color indicator dot
            Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),
            // Category name + bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.categoryName,
                            style: AppTextStyles.bodyLarge,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatCurrency(item.totalAmount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: color.withOpacity(0.12),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$pctStr%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
