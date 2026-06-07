import 'package:financial_app/feature/aicoaching/presentation/bloc/aicoaching_bloc.dart';
import 'package:financial_app/feature/aicoaching/presentation/bloc/aicoaching_event.dart';
import 'package:financial_app/feature/aicoaching/presentation/bloc/aicoaching_state.dart';
import 'package:financial_app/feature/aicoaching/presentation/pages/aicoaching_page.dart';
import 'package:financial_app/feature/auth/presentation/pages/profile_page.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_event.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_state.dart';
import 'package:financial_app/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:financial_app/feature/budget/presentation/widgets/budget_card.dart';
import 'package:financial_app/feature/category/presentation/bloc/category_bloc.dart';
import 'package:financial_app/feature/transaction/presentation/bloc/report_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_event.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/core/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:financial_app/feature/wallet/presentation/widgets/add_wallet_bottom_sheet.dart';

import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../widgets/edit_transaction_bottom_sheet.dart';
import '../../domain/entities/transaction_entity.dart';
import 'report_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _showBalance = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchTransactions());
    context.read<WalletBloc>().add(FetchWallets());
    context.read<BudgetBloc>().add(FetchBudgets());
    context.read<AICoachingBloc>().add(LoadAICoachingEvent());
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userName = prefs.getString('user_name') ?? '');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _getTodayLabel() {
    final now = DateTime.now();
    const weekdays = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    return '${weekdays[now.weekday]}, ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _formatCurrency(double amount) {
    final result = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return _showBalance ? '$result đ' : '•••••• ';
  }

  String _formatCurrencyShort(double amount) {
    if (!_showBalance) return '••••';
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}tr';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}k';
    return amount.toStringAsFixed(0);
  }

  // Smart icon based on transaction note keywords
  Widget _buildSmartTransactionIcon(String? note, bool isIncome) {
    IconData iconData = isIncome ? Icons.monetization_on_rounded : Icons.shopping_bag_rounded;
    Color bgColor = isIncome ? AppColors.incomeBg : AppColors.expenseBg;
    Color iconColor = isIncome ? AppColors.income : AppColors.expense;

    final lowerNote = (note ?? '').toLowerCase();
    if (!isIncome) {
      if (lowerNote.contains('ăn') || lowerNote.contains('uống') || lowerNote.contains('cà phê')) {
        iconData = Icons.fastfood_rounded; bgColor = Colors.orange.shade50; iconColor = Colors.deepOrange;
      } else if (lowerNote.contains('phim') || lowerNote.contains('giải trí') || lowerNote.contains('chơi')) {
        iconData = Icons.movie_creation_rounded; bgColor = Colors.purple.shade50; iconColor = Colors.purple;
      } else if (lowerNote.contains('xe') || lowerNote.contains('xăng') || lowerNote.contains('gửi xe')) {
        iconData = Icons.directions_car_rounded; bgColor = Colors.blue.shade50; iconColor = Colors.blue.shade700;
      } else if (lowerNote.contains('điện') || lowerNote.contains('nước') || lowerNote.contains('mạng')) {
        iconData = Icons.bolt_rounded; bgColor = Colors.yellow.shade100; iconColor = Colors.amber.shade800;
      } else if (lowerNote.contains('shopee') || lowerNote.contains('mua sắm') || lowerNote.contains('quần áo')) {
        iconData = Icons.shopping_cart_rounded; bgColor = Colors.pink.shade50; iconColor = Colors.pink;
      }
    } else {
      if (lowerNote.contains('lương')) { iconData = Icons.account_balance_rounded; bgColor = Colors.teal.shade50; iconColor = Colors.teal.shade700; }
      else if (lowerNote.contains('thưởng')) { iconData = Icons.card_giftcard_rounded; bgColor = Colors.indigo.shade50; iconColor = Colors.indigo; }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  // ── Date grouping helpers ──────────────────────────────────────────────────
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

  /// Builds flat list: alternating [String=dateHeader, TransactionEntity, ...]
  List<dynamic> _buildGroupedItems(List<TransactionEntity> transactions) {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final items = <dynamic>[];
    String? lastDate;
    for (final t in sorted) {
      final date = t.date.split(' ')[0];
      if (date != lastDate) { items.add(date); lastDate = date; }
      items.add(t);
    }
    return items;
  }

  // ── Main build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            const ReportPage(),
            const SizedBox.shrink(),
            const AiCoachingPage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HOME TAB ───────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TransactionBloc>().add(FetchTransactions());
        context.read<WalletBloc>().add(FetchWallets());
        context.read<BudgetBloc>().add(FetchBudgets());
        context.read<AICoachingBloc>().add(LoadAICoachingEvent());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Greeting header ──
          SliverToBoxAdapter(child: _buildGreetingHeader()),
          // ── Balance hero card ──
          SliverToBoxAdapter(child: _buildBalanceCard()),
          // ── Wallet chips row ──
          SliverToBoxAdapter(child: _buildWalletRow()),
          // ── AI insight compact ──
          SliverToBoxAdapter(child: _buildAIInsightBar()),
          // ── Budget section (summary + cards) ──
          SliverToBoxAdapter(child: _buildBudgetSection()),
          // ── Transaction list header ──
          SliverToBoxAdapter(child: _buildTransactionHeader()),
          // ── Transaction list (grouped) ──
          _buildTransactionSliver(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── ZONE A: Greeting header ────────────────────────────────────────────────
  Widget _buildGreetingHeader() {
    final firstName = _userName.split(' ').last;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryMid, AppColors.primary]),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
              style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}${firstName.isNotEmpty ? ", $firstName!" : "!"}',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(_getTodayLabel(), style: AppTextStyles.caption),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/notifications'),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [BoxShadow(color: AppColors.shadowBase.withOpacity(0.06), blurRadius: 8)],
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ── ZONE B: Balance hero card ──────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        double totalIncome = 0, totalExpense = 0;
        if (state is TransactionLoaded) {
          for (final t in state.transactions) {
            if (t.type == 'Thu') totalIncome += t.amount;
            else if (t.type == 'Chi') totalExpense += t.amount;
          }
        }
        final totalBalance = totalIncome - totalExpense;
        final isPositive = totalBalance >= 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPositive
                  ? [const Color(0xFF1A6B47), const Color(0xFF0D3D28)]
                  : [const Color(0xFF8B2020), const Color(0xFF4D0E0E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: (isPositive ? AppColors.primaryDark : AppColors.expense).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label + toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TỔNG SỐ DƯ',
                    style: AppTextStyles.label.copyWith(color: Colors.white.withOpacity(0.65), letterSpacing: 1.2),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showBalance = !_showBalance),
                    child: Icon(
                      _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Big balance number
              Text(
                _formatCurrency(totalBalance),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Income / Expense pills
              Row(
                children: [
                  Expanded(
                    child: _buildBalancePill(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Tiền vào',
                      amount: totalIncome,
                      color: const Color(0xFF69F0AE),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildBalancePill(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Tiền ra',
                      amount: totalExpense,
                      color: const Color(0xFFFF8A80),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalancePill({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.65))),
                const SizedBox(height: 2),
                Text(
                  _formatCurrency(amount),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Wallet chips row ───────────────────────────────────────────────────────
  Widget _buildWalletRow() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is! WalletLoaded) return const SizedBox(height: AppSpacing.sm);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row label + "Xem tất cả" link
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ví của tôi', style: AppTextStyles.h4),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/wallets'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Quản lý', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  ...state.wallets.map((w) => Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: AppColors.shadowBase.withOpacity(0.04), blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, size: 13, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(w.name, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(width: 4),
                        Text(_formatCurrencyShort(w.currentBalance), style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )),
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BlocProvider.value(
                          value: context.read<WalletBloc>(),
                          child: const AddWalletBottomSheet(),
                        ),
                      );
                      if (result == true && context.mounted) {
                        context.read<WalletBloc>().add(const FetchWallets());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('Thêm ví', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── ZONE D: AI Insight compact ─────────────────────────────────────────────
  Widget _buildAIInsightBar() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      builder: (context, state) {
        String text = 'AI đang phân tích chi tiêu của bạn...';
        if (state is AICoachingLoaded) text = state.coachingData.review;
        if (state is AICoachingError) text = 'Không thể tải nhận xét AI.';

        return GestureDetector(
          onTap: () => setState(() => _currentIndex = 3),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2E4A),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.amber),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: state is AICoachingLoading
                      ? Text('Đang phân tích...', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic))
                      : Text(
                          text,
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.85), fontStyle: FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.amber),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── ZONE E: Budget section (summary bar + individual cards) ──────────────
  Widget _buildBudgetSection() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ngân sách tháng', style: AppTextStyles.h4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/saving-goals'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.savings_rounded, size: 13, color: Colors.teal),
                            const SizedBox(width: 3),
                            Text('Mục tiêu', style: AppTextStyles.caption.copyWith(color: Colors.teal, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => showModalBottomSheet(
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Loading
            if (state is BudgetLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
              )

            // Empty state — invite to add
            else if (state is! BudgetLoaded || state.budgets.isEmpty)
              GestureDetector(
                onTap: () => showModalBottomSheet(
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
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: AppSpacing.md),
                      Text('Thiết lập ngân sách tháng này', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              )

            // Has budgets — show summary bar + individual cards
            else ...[
              // Compact summary bar
              _buildBudgetSummaryBar(state),

              // Individual budget cards (max 3)
              ...state.budgets.take(3).map((b) => BudgetCard(budget: b)),

              // "Xem tất cả" if more than 3
              if (state.budgets.length > 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem tất cả ${state.budgets.length} ngân sách',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBudgetSummaryBar(BudgetLoaded state) {
    final totalLimit = state.budgets.fold<double>(0, (s, b) => s + b.limit);
    final totalSpent = state.budgets.fold<double>(0, (s, b) => s + b.spent);
    final ratio = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final remaining = totalLimit - totalSpent;

    Color barColor;
    if (ratio >= 0.9) barColor = AppColors.expense;
    else if (ratio >= 0.7) barColor = AppColors.warning;
    else barColor = AppColors.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: AppWidgets.cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_rounded, size: 15, color: barColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tổng: ${_formatCurrencyShort(totalSpent)} / ${_formatCurrencyShort(totalLimit)}',
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                remaining >= 0 ? 'Còn ${_formatCurrencyShort(remaining)}' : 'Vượt ${_formatCurrencyShort(-remaining)}',
                style: AppTextStyles.caption.copyWith(
                  color: remaining >= 0 ? barColor : AppColors.expense,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${(ratio * 100).toInt()}%',
                style: AppTextStyles.caption.copyWith(color: barColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ZONE F: Transaction list (grouped by date, as sliver) ─────────────────
  Widget _buildTransactionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Giao dịch gần đây', style: AppTextStyles.h4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/transactions'),
            child: Text(
              'Xem tất cả',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSliver() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          );
        }

        if (state is TransactionLoaded) {
          if (state.transactions.isEmpty) {
            return SliverToBoxAdapter(
              child: AppWidgets.emptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Chưa có giao dịch nào',
                subtitle: 'Nhấn + để ghi chép giao dịch đầu tiên',
              ),
            );
          }

          // Show max 7 recent transactions, grouped
          final recent = state.transactions.length > 7
              ? state.transactions.sublist(0, 7)
              : state.transactions;
          final grouped = _buildGroupedItems(recent);

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = grouped[index];
                  if (item is String) {
                    return _buildDateSeparator(item);
                  }
                  if (item is TransactionEntity) {
                    return _buildTransactionTile(item);
                  }
                  return const SizedBox();
                },
                childCount: grouped.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildDateSeparator(String dateStr) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            _dateHeaderLabel(dateStr),
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
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
      key: Key('tx_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: AppColors.expense.withOpacity(0.85), borderRadius: BorderRadius.circular(AppRadius.lg)),
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
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Xóa', style: TextStyle(color: AppColors.expense))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        context.read<TransactionBloc>().add(DeleteTransactionPressed(id: item.id));
        context.read<ReportBloc>().add(FetchCategorySpending());
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
            context.read<ReportBloc>().add(FetchCategorySpending());
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: AppWidgets.cardDecoration(radius: AppRadius.lg),
          child: Row(
            children: [
              _buildSmartTransactionIcon(item.note, isIncome),
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

  // ── BOTTOM NAVIGATION ──────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.shadowBase.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Tổng quan'),
              _navItem(1, Icons.analytics_rounded, Icons.analytics_outlined, 'Báo cáo'),
              // Center FAB slot
              _buildCenterFAB(),
              _navItem(3, Icons.psychology_rounded, Icons.psychology_outlined, 'AI Coach'),
              _navItem(4, Icons.person_rounded, Icons.person_outlined, 'Tài khoản'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFAB() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: GestureDetector(
        onTap: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionBottomSheet(),
          );
          if (result == true && context.mounted) {
            context.read<TransactionBloc>().add(FetchTransactions());
            context.read<ReportBloc>().add(FetchCategorySpending());
          }
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryMid, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
