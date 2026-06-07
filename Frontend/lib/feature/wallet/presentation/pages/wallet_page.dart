import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../widgets/add_wallet_bottom_sheet.dart';
import '../../data/models/wallet_model.dart';
import '../../../../core/constants/app_theme.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const FetchWallets());
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
        title: 'Ví của tôi',
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is WalletError) {
            return AppWidgets.emptyState(
              icon: Icons.wifi_off_rounded,
              title: 'Không thể tải dữ liệu',
              subtitle: state.message,
              action: ElevatedButton.icon(
                onPressed: () => context.read<WalletBloc>().add(const FetchWallets()),
                style: AppWidgets.primaryButtonStyle(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại', style: AppTextStyles.buttonSmall),
              ),
            );
          }

          if (state is WalletLoaded) {
            if (state.wallets.isEmpty) {
              return AppWidgets.emptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Chưa có ví nào',
                subtitle: 'Thêm ví đầu tiên để bắt đầu theo dõi tài chính',
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<WalletBloc>().add(const FetchWallets()),
              child: Column(
                children: [
                  _buildTotalCard(state.wallets),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        100,
                      ),
                      itemCount: state.wallets.length,
                      itemBuilder: (context, i) =>
                          _buildWalletCard(state.wallets[i]),
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
            builder: (_) => BlocProvider.value(
              value: context.read<WalletBloc>(),
              child: const AddWalletBottomSheet(),
            ),
          );
          if (result == true && context.mounted) {
            context.read<WalletBloc>().add(const FetchWallets());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ví', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// Card tổng số dư tất cả ví
  Widget _buildTotalCard(List<WalletModel> wallets) {
    final total = wallets.fold<double>(0, (sum, w) => sum + w.currentBalance);
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryMid, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.account_balance_rounded, color: AppColors.textOnPrimary, size: 26),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng số dư',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnPrimary.withOpacity(0.8)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatCurrency(total),
                  style: AppTextStyles.amountLarge.copyWith(color: AppColors.textOnPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${wallets.length} ví',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card từng ví
  Widget _buildWalletCard(WalletModel wallet) {
    final icons = [
      Icons.account_balance_wallet_rounded,
      Icons.credit_card_rounded,
      Icons.savings_rounded,
      Icons.payments_rounded,
    ];
    final iconIndex = wallet.id % icons.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppWidgets.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icons[iconIndex], color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wallet.name, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Số dư ban đầu: ${_formatCurrency(wallet.initialBalance)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(wallet.currentBalance),
                style: AppTextStyles.amountIncome,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Hiện tại', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
