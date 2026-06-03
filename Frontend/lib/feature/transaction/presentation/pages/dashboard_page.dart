import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_state.dart';
import 'package:financial_app/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:financial_app/feature/budget/presentation/widgets/budget_card.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/add_transaction_bottom_sheet.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool _showBalance = true;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchTransactions());
  }

  String _formatCurrency(double amount) {
    String result = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return _showBalance ? '$result đ' : '•••••• ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(FetchTransactions());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildDynamicMasterWalletCard(),
                _buildAICoachingCard(),
                _buildGamificationTasksCard(),
                _buildBudgetSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giao dịch gần đây',
                        style: TextStyle(
                          fontSize: 15, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF2C3E50)
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Xem tất cả', 
                          style: TextStyle(color: Colors.green.shade700)
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTransactionList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ngân sách tháng này',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF27AE60)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddBudgetBottomSheet(),
                  );
                },
              ),
            ],
          ),
        ),
        BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state is BudgetLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is BudgetLoaded) {
              if (state.budgets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Chưa thiết lập ngân sách nào.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.budgets.length,
                itemBuilder: (context, index) {
                  return BudgetCard(budget: state.budgets[index]);
                },
              );
            }
            if (state is BudgetError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Lỗi: ${state.message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildDynamicMasterWalletCard() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, transactionState) {
        double totalIncome = 0;
        double totalExpense = 0;
        double totalBalance = 0;

        if (transactionState is TransactionLoaded) {
          for (var item in transactionState.transactions) {
            if (item.type == 'Thu') totalIncome += item.amount;
            else if (item.type == 'Chi') totalExpense += item.amount;
          }
          totalBalance = totalIncome - totalExpense;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), 
                blurRadius: 12, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Tổng số dư',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showBalance = !_showBalance),
                        child: Icon(
                          _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFF0F3F2), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none, size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              Text(
                _formatCurrency(totalBalance),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFE8F8F5), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tiền vào', style: TextStyle(fontSize: 10, color: Color(0xFF16A085))),
                          Text(_formatCurrency(totalIncome), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFFCE4D6), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tiền ra', style: TextStyle(fontSize: 10, color: Color(0xFFC0392B))),
                          Text(_formatCurrency(totalExpense), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE74C3C))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 12),
              SizedBox(
                height: 65,
                child: BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, walletState) {
                    if (walletState is WalletLoading) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    if (walletState is WalletLoaded) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: walletState.wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = walletState.wallets[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet, size: 20, color: Color(0xFF16A085)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(wallet.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87), overflow: TextOverflow.ellipsis),
                                      Text(_showBalance ? _formatCurrency(wallet.balance) : '•••••• ', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: Text('Lỗi tải ví', style: TextStyle(fontSize: 12, color: Colors.red)));
                  }
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAICoachingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F4068), Color(0xFF162447)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
              SizedBox(width: 6),
              Text('AI FINANCIAL COACHING', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1))
            ]
          ),
          SizedBox(height: 8),
          Text(
            '"Tốc độ chi tiêu tuần này của bạn đang giảm 12% so với tuần trước. Rất tốt! Mục tiêu tiết kiệm mua xe Xpander đang đi đúng tiến độ 85%."',
            style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.4, fontStyle: FontStyle.italic),
          )
        ]
      )
    );
  }

  Widget _buildGamificationTasksCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.emoji_events_outlined, color: Colors.orange, size: 20),
                  SizedBox(width: 6),
                  Text('Thử thách tích lũy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                ],
              ),
              Text('1/2 Hoàn thành', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          _buildTaskItem('Ghi chép 1 giao dịch thu chi bất kỳ', true),
          const SizedBox(height: 8),
          _buildTaskItem('Xem nhận xét chi tiết từ Trợ lý AI', false),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskName, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? const Color(0xFF27AE60) : Colors.grey.shade300,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            taskName,
            style: TextStyle(
              fontSize: 12.5,
              color: isCompleted ? Colors.grey.shade500 : const Color(0xFF34495E),
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (!isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Text('+20 Exp', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TransactionLoaded) {
          final transactions = state.transactions;
          if (transactions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Chưa có giao dịch nào trong tháng này.', style: TextStyle(color: Colors.grey, fontSize: 13))),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final item = transactions[index];
              final isIncome = item.type == 'Thu';
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? const Color(0xFFE8F8F5) : const Color(0xFFFCE4D6),
                    radius: 18,
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                      size: 16,
                    ),
                  ),
                  title: Text(item.note ?? 'Giao dịch không có ghi chú', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: Color(0xFF2C3E50))),
                  subtitle: Text(item.date.split(' ')[0], style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                  trailing: Text(
                    '${isIncome ? "+" : "-"}${_formatCurrency(item.amount)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C)),
                  ),
                ),
              );
            },
          );
        }
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('Không thể kết nối đến máy chủ Laravel.', style: TextStyle(color: Colors.grey, fontSize: 13))),
        );
      }
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      height: 65,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(0, Icons.account_balance_wallet, 'Tổng quan'),
          _buildBottomNavItem(1, Icons.analytics_outlined, 'Báo cáo'),
          Transform.translate(
            offset: const Offset(0, -10),
            child: SizedBox(
              width: 46,
              height: 46,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddTransactionBottomSheet(),
                  );
                  if (result == true && context.mounted) {
                    context.read<TransactionBloc>().add(FetchTransactions());
                  }
                },
                backgroundColor: const Color(0xFF27AE60),
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
          _buildBottomNavItem(3, Icons.psychology, 'AI Coach'),
          _buildBottomNavItem(4, Icons.person_outline, 'Tài khoản'),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF27AE60) : Colors.grey.shade500;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}