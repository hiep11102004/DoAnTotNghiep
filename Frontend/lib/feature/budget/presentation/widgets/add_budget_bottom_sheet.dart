import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget_bloc.dart';

class AddBudgetBottomSheet extends StatefulWidget {
  const AddBudgetBottomSheet({super.key});

  @override
  State<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends State<AddBudgetBottomSheet> {
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController(); // Tạm dùng input ID, sau này đổi thành Dropdown

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Thiết lập ngân sách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category ID (ví dụ: 1)')),
          TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Hạn mức (Số tiền)'), keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<BudgetBloc>().add(AddBudget(
                categoryId: int.parse(_categoryController.text),
                amountLimit: double.parse(_amountController.text),
              ));
              Navigator.pop(context);
            },
            child: const Text('Lưu ngân sách'),
          ),
        ],
      ),
    );
  }
}