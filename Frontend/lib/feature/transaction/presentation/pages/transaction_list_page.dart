import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
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
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    ) + ' đ';
  }

  List<TransactionEntity> _applyFilter(List<TransactionEntity> all) {
    if (_filter == 'Thu') return all.where((t) => t.type == 'Thu').toList();
    if (_filter == 'Chi') return all.where((t) => t.type == 'Chi').toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Tất cả giao dịch', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _filterChip('all', 'Tất cả'),
          const SizedBox(width: 8),
          _filterChip('Thu', 'Thu nhập'),
          const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF27AE60) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TransactionFailure) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        if (state is TransactionLoaded) {
          final filtered = _applyFilter(state.transactions);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Không có giao dịch nào', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<TransactionBloc>().add(FetchTransactions()),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildTransactionTile(item);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTransactionTile(TransactionEntity item) {
    final isIncome = item.type == 'Thu';

    return Dismissible(
      key: Key('tl_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xóa giao dịch'),
            content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xFFE8F8F5) : const Color(0xFFFCE4D6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.note ?? 'Không có ghi chú',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF2C3E50)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.date.split(' ')[0],
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? "+" : "-"}${_formatCurrency(item.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
