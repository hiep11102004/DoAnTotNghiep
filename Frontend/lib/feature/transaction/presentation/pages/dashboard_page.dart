import 'package:financial_app/feature/aicoaching/presentation/pages/aicoaching_page.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_state.dart';
import 'package:financial_app/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart';
import 'package:financial_app/feature/budget/presentation/widgets/budget_card.dart';
import 'package:financial_app/feature/transaction/presentation/bloc/report_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_event.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:financial_app/feature/wallet/presentation/widgets/add_wallet_bottom_sheet.dart'; 

import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import 'report_page.dart';

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
    // Kéo dữ liệu giao dịch
    context.read<TransactionBloc>().add(FetchTransactions());
    
    // Kéo dữ liệu Ví ngay khi mở app
    context.read<WalletBloc>().add(FetchWallets()); 
  }

  String _formatCurrency(double amount) {
    String result = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return _showBalance ? '$result đ' : '•••••• ';
  }

  Widget _buildSmartTransactionIcon(String? note, bool isIncome) {
    IconData iconData = isIncome ? Icons.monetization_on_rounded : Icons.shopping_bag_rounded;
    Color bgColor = isIncome ? const Color(0xFFE8F8F5) : const Color(0xFFFCE4D6);
    Color iconColor = isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C);

    String lowerNote = (note ?? '').toLowerCase();

    if (!isIncome) {
      if (lowerNote.contains('ăn') || lowerNote.contains('uống') || lowerNote.contains('kichi') || lowerNote.contains('cà phê')) {
        iconData = Icons.fastfood_rounded;
        bgColor = Colors.orange.shade50;
        iconColor = Colors.deepOrange;
      } else if (lowerNote.contains('phim') || lowerNote.contains('giải trí') || lowerNote.contains('chơi')) {
        iconData = Icons.movie_creation_rounded;
        bgColor = Colors.purple.shade50;
        iconColor = Colors.purple;
      } else if (lowerNote.contains('xe') || lowerNote.contains('xpander') || lowerNote.contains('xăng') || lowerNote.contains('gửi xe')) {
        iconData = Icons.directions_car_rounded;
        bgColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
      } else if (lowerNote.contains('điện') || lowerNote.contains('nước') || lowerNote.contains('mạng')) {
        iconData = Icons.bolt_rounded;
        bgColor = Colors.yellow.shade100;
        iconColor = Colors.amber.shade800;
      } else if (lowerNote.contains('mua sắm') || lowerNote.contains('shopee') || lowerNote.contains('quần áo')) {
        iconData = Icons.shopping_cart_rounded;
        bgColor = Colors.pink.shade50;
        iconColor = Colors.pink;
      }
    } else {
      if (lowerNote.contains('lương')) {
        iconData = Icons.account_balance_rounded;
        bgColor = Colors.teal.shade50;
        iconColor = Colors.teal.shade700;
      } else if (lowerNote.contains('thưởng')) {
        iconData = Icons.card_giftcard_rounded;
        bgColor = Colors.indigo.shade50;
        iconColor = Colors.indigo;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardContent(), 
            const ReportPage(),       
            const SizedBox.shrink(),  
            const AiCoachingPage(),
            const Center(child: Text("Tính năng Tài khoản đang phát triển", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionBloc>().add(FetchTransactions());
        context.read<WalletBloc>().add(FetchWallets()); 
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
            _buildTransactionList(),       
            const SizedBox(height: 100),
          ],
        ),
      ),
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
              return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
            }
            if (state is BudgetLoaded) {
              if (state.budgets.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Chưa thiết lập ngân sách nào.", style: TextStyle(color: Colors.grey)),
                );
              }
              
              final displayBudgets = state.budgets.take(2).toList();
              
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayBudgets.length,
                    itemBuilder: (context, index) {
                      return BudgetCard(budget: displayBudgets[index]);
                    },
                  ),
                  if (state.budgets.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: TextButton(
                        onPressed: () {},
                        child: Text('Xem tất cả ${state.budgets.length} ngân sách', 
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                ],
              );
            }
            if (state is BudgetError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Lỗi: ${state.message}", style: const TextStyle(color: Colors.red)),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF203A43).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
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
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showBalance = !_showBalance),
                        child: Icon(
                          _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none, size: 18, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatCurrency(totalBalance),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tiền vào', style: TextStyle(fontSize: 11, color: Color(0xFF69F0AE))),
                          const SizedBox(height: 4),
                          Text(_formatCurrency(totalIncome), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tiền ra', style: TextStyle(fontSize: 11, color: Color(0xFFFF8A80))),
                          const SizedBox(height: 4),
                          Text(_formatCurrency(totalExpense), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Danh sách ví của bạn', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddWalletBottomSheet(),
                      );
                      if (result == true && context.mounted) {
                        context.read<WalletBloc>().add(FetchWallets());
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle, color: Color(0xFF69F0AE), size: 16),
                        SizedBox(width: 4),
                        Text('Thêm', style: TextStyle(fontSize: 11, color: Color(0xFF69F0AE), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),

              // 🛠️ ĐOẠN CODE HIỂN THỊ VÍ ĐÃ ĐƯỢC NÂNG CẤP ĐỂ HIỆN RÕ LỖI
              SizedBox(
                height: 65,
                child: BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, walletState) {
                    // 1. Trạng thái khởi tạo hoặc đang tải
                    if (walletState is WalletInitial || walletState is WalletLoading) {
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
                    }
                    
                    // 2. Tải thành công
                    if (walletState is WalletLoaded) {
                      if (walletState.wallets.isEmpty) {
                        return Center(child: Text('Chưa có ví nào. Hãy bấm + Thêm ví', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      }
                      
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: walletState.wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = walletState.wallets[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(wallet.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                                      Text(_showBalance ? _formatCurrency(wallet.balance) : '•••••• ', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    
                    // 3. 🛠️ TRẠNG THÁI LỖI: IN CHÍNH XÁC THÔNG BÁO LỖI RA UI
                    if (walletState is WalletError) {
                      return Center(
                        child: Text(
                          'Lỗi tải ví: ${walletState.message}', 
                          style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    
                    return const Center(child: Text('Đang tải...', style: TextStyle(fontSize: 12, color: Colors.orange)));
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF4F8FD), Color(0xFFE5EDF8)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)]),
                    child: const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Bảng Nhiệm Vụ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade200)),
                child: const Text('1/2 Xong', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTaskItem('Ghi chép 1 giao dịch', '+20 Exp', true),
          const SizedBox(height: 10),
          _buildTaskItem('Đọc nhận xét từ AI Coach', '+50 Exp', false),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskName, String reward, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: isCompleted ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.grey.shade100 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.emoji_events_rounded,
              color: isCompleted ? Colors.green : Colors.orange.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              taskName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCompleted ? Colors.grey.shade500 : const Color(0xFF34495E),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (!isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFB75E), Color(0xFFED8F03)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(reward, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Padding(padding: EdgeInsets.all(24.0), child: Center(child: CircularProgressIndicator()));
        }
        if (state is TransactionLoaded) {
          final transactions = state.transactions;
          if (transactions.isEmpty) return const SizedBox();
          
          final displayTransactions = transactions.take(3).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Giao dịch gần đây', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayTransactions.length,
                itemBuilder: (context, index) {
                  final item = displayTransactions[index];
                  final isIncome = item.type == 'Thu';
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), 
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _buildSmartTransactionIcon(item.note, isIncome),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.note ?? 'Không có ghi chú', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF2C3E50)), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(item.date.split(' ')[0], style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? "+" : "-"}${_formatCurrency(item.amount)}',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (transactions.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_left, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text('Vuốt sang tab Báo cáo để xem toàn bộ', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                )
            ],
          );
        }
        return const SizedBox();
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
                    context.read<ReportBloc>().add(FetchCategorySpending());
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