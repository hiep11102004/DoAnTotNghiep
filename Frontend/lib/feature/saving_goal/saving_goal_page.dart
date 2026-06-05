import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'saving_goal_bloc.dart';
import 'saving_goal_datasource.dart';

class SavingGoalPage extends StatefulWidget {
  const SavingGoalPage({super.key});

  @override
  State<SavingGoalPage> createState() => _SavingGoalPageState();
}

class _SavingGoalPageState extends State<SavingGoalPage> {
  @override
  void initState() {
    super.initState();
    context.read<SavingGoalBloc>().add(FetchSavingGoals());
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    ) + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavingGoalBloc, SavingGoalState>(
      listener: (context, state) {
        if (state is SavingGoalActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is SavingGoalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        appBar: AppBar(
          title: const Text('Mục tiêu tiết kiệm', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF27AE60)),
              onPressed: () => _showAddGoalSheet(context),
            ),
          ],
        ),
        body: BlocBuilder<SavingGoalBloc, SavingGoalState>(
          builder: (context, state) {
            if (state is SavingGoalLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SavingGoalLoaded) {
              if (state.goals.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Chưa có mục tiêu nào', style: TextStyle(color: Colors.grey, fontSize: 15)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<SavingGoalBloc>().add(FetchSavingGoals()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.goals.length,
                  itemBuilder: (context, index) => _buildGoalCard(context, state.goals[index]),
                ),
              );
            }
            if (state is SavingGoalError) {
              return Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingGoalModel goal) {
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(goal.goalName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _showEditGoalSheet(context, goal);
                  if (value == 'delete') _confirmDelete(context, goal.id, goal.goalName);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Sửa')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatCurrency(goal.currentAmount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF27AE60))),
              Text(_formatCurrency(goal.targetAmount), style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : const Color(0xFF27AE60)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$percent% hoàn thành', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              if (goal.deadline != null)
                Text('Hạn: ${goal.deadline}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: goal.status == 'Hoàn thành' ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(goal.status, style: TextStyle(fontSize: 11, color: goal.status == 'Hoàn thành' ? Colors.green : Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    _showGoalFormSheet(context, null);
  }

  void _showEditGoalSheet(BuildContext context, SavingGoalModel goal) {
    _showGoalFormSheet(context, goal);
  }

  void _showGoalFormSheet(BuildContext context, SavingGoalModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.goalName ?? '');
    final targetCtrl = TextEditingController(text: existing != null ? existing.targetAmount.toStringAsFixed(0) : '');
    final currentCtrl = TextEditingController(text: existing != null ? existing.currentAmount.toStringAsFixed(0) : '0');
    String? deadline = existing?.deadline;
    String status = existing?.status ?? 'Đang thực hiện';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Thêm mục tiêu' : 'Sửa mục tiêu',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Tên mục tiêu', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Số tiền mục tiêu', suffixText: 'đ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Đã tiết kiệm được', suffixText: 'đ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadline != null ? DateTime.tryParse(deadline!) ?? DateTime.now() : DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setSheetState(() => deadline = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(deadline ?? 'Chọn hạn chót (tuỳ chọn)', style: const TextStyle(fontSize: 14)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(targetCtrl.text) ?? 0;
                    final current = double.tryParse(currentCtrl.text) ?? 0;
                    if (name.isEmpty || target <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên và số tiền mục tiêu')));
                      return;
                    }
                    Navigator.pop(ctx);
                    if (existing == null) {
                      context.read<SavingGoalBloc>().add(AddSavingGoal(goalName: name, targetAmount: target, currentAmount: current, deadline: deadline));
                    } else {
                      context.read<SavingGoalBloc>().add(UpdateSavingGoal(id: existing.id, goalName: name, targetAmount: target, currentAmount: current, deadline: deadline, status: status));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(existing == null ? 'Thêm mục tiêu' : 'Lưu thay đổi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: Text('Xóa mục tiêu "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SavingGoalBloc>().add(DeleteSavingGoal(id));
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
