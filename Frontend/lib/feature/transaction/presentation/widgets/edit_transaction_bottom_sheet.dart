import 'package:financial_app/feature/category/presentation/bloc/category_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class EditTransactionBottomSheet extends StatefulWidget {
  final TransactionEntity transaction;

  const EditTransactionBottomSheet({super.key, required this.transaction});

  @override
  State<EditTransactionBottomSheet> createState() => _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState extends State<EditTransactionBottomSheet> {
  late bool _isIncome;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late int? _selectedWalletId;
  late int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.transaction.type == 'Thu';
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: widget.transaction.note ?? '');
    _selectedWalletId = widget.transaction.walletId;
    _selectedCategoryId = widget.transaction.categoryId;
    try {
      _selectedDate = DateTime.parse(widget.transaction.date.split(' ')[0]);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF27AE60))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submitUpdate() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')));
      return;
    }
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ví và danh mục')));
      return;
    }

    context.read<TransactionBloc>().add(UpdateTransactionSubmitted(
      id: widget.transaction.id,
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      amount: amount,
      type: _isIncome ? 'Thu' : 'Chi',
      date: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      note: _noteController.text.isEmpty ? null : _noteController.text,
      status: widget.transaction.status,
      source: widget.transaction.source,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionActionSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is TransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Sửa giao dịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                const SizedBox(height: 20),

                // Toggle Thu/Chi
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isIncome = false; _selectedCategoryId = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isIncome ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text('Tiền ra (Chi)', style: TextStyle(fontWeight: FontWeight.bold, color: !_isIncome ? const Color(0xFFE74C3C) : Colors.grey.shade500)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isIncome = true; _selectedCategoryId = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isIncome ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text('Tiền vào (Thu)', style: TextStyle(fontWeight: FontWeight.bold, color: _isIncome ? const Color(0xFF27AE60) : Colors.grey.shade500)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Wallet dropdown
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    final wallets = state is WalletLoaded ? state.wallets : [];
                    return DropdownButtonFormField<int>(
                      value: _selectedWalletId,
                      decoration: InputDecoration(
                        labelText: 'Chọn Ví',
                        prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF27AE60)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: wallets.map((w) => DropdownMenuItem<int>(value: w.id, child: Text(w.name))).toList(),
                      onChanged: (v) => setState(() => _selectedWalletId = v),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Category dropdown
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      final targetType = _isIncome ? 'income' : 'expense';
                      final filtered = state.categories.where((c) => c.type == targetType).toList();
                      if (_selectedCategoryId != null && !filtered.any((c) => c.id == _selectedCategoryId)) {
                        _selectedCategoryId = filtered.isNotEmpty ? filtered.first.id : null;
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Chọn Danh mục',
                          prefixIcon: const Icon(Icons.category, color: Colors.blueAccent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: filtered.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C)),
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    suffixText: 'đ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Note
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Date picker
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cập nhật giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
