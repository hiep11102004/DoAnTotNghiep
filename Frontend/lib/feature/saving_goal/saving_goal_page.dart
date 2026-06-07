import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/core/constants/app_theme.dart';
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
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.income,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          );
        } else if (state is SavingGoalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.expense,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppWidgets.appBar(
          title: 'Mục tiêu tiết kiệm',
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
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
              return AppWidgets.emptyState(
                icon: Icons.savings_outlined,
                title: 'Chưa có mục tiêu nào',
                subtitle: 'Tạo mục tiêu tiết kiệm đầu tiên để bắt đầu hành trình tài chính',
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
    final double progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).toStringAsFixed(0);
    final isCompleted = goal.status == 'Hoàn thành' || progress >= 1.0;
    final remaining = goal.targetAmount - goal.currentAmount;

    // Dynamic progress color
    Color progressColor;
    Color progressBg;
    if (isCompleted) {
      progressColor = AppColors.income;
      progressBg = AppColors.incomeBg;
    } else if (progress >= 0.8) {
      progressColor = AppColors.warning;
      progressBg = AppColors.warningBg;
    } else {
      progressColor = AppColors.primary;
      progressBg = AppColors.primaryLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppWidgets.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: progressBg, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Icon(Icons.savings_rounded, color: progressColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(goal.goalName, style: AppTextStyles.bodyLarge),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') _showEditGoalSheet(context, goal);
                    if (value == 'delete') _confirmDelete(context, goal.id, goal.goalName);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Sửa')])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outlined, size: 16, color: AppColors.expense), const SizedBox(width: 8), Text('Xóa', style: TextStyle(color: AppColors.expense))])),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đã tiết kiệm', style: AppTextStyles.caption),
                        Text(_formatCurrency(goal.currentAmount), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: progressColor)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isCompleted ? 'Hoàn thành!' : 'Còn thiếu', style: AppTextStyles.caption),
                        Text(
                          isCompleted ? '🎉 ${_formatCurrency(goal.targetAmount)}' : _formatCurrency(remaining),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? AppColors.income : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Footer: percent + deadline + status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(color: progressBg, borderRadius: BorderRadius.circular(AppRadius.full)),
                      child: Text('$percent%', style: AppTextStyles.caption.copyWith(color: progressColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (goal.deadline != null)
                      Text('Hạn: ${goal.deadline}', style: AppTextStyles.caption),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.incomeBg : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        goal.status,
                        style: AppTextStyles.caption.copyWith(
                          color: isCompleted ? AppColors.income : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(existing == null ? 'Thêm mục tiêu' : 'Sửa mục tiêu', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: nameCtrl,
                style: AppTextStyles.body,
                decoration: AppWidgets.inputDecoration(
                  label: 'Tên mục tiêu',
                  prefixIcon: const Icon(Icons.flag_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.body,
                decoration: AppWidgets.inputDecoration(
                  label: 'Số tiền mục tiêu',
                  prefixIcon: const Icon(Icons.track_changes_rounded, color: AppColors.primary),
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.body,
                decoration: AppWidgets.inputDecoration(
                  label: 'Đã tiết kiệm được',
                  prefixIcon: const Icon(Icons.savings_rounded, color: AppColors.primary),
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadline != null ? DateTime.tryParse(deadline!) ?? DateTime.now() : DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setSheetState(() => deadline = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      deadline ?? 'Chọn hạn chót (tuỳ chọn)',
                      style: AppTextStyles.body.copyWith(color: deadline != null ? AppColors.textPrimary : AppColors.textHint),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(targetCtrl.text.replaceAll(',', '')) ?? 0;
                    final current = double.tryParse(currentCtrl.text.replaceAll(',', '')) ?? 0;
                    if (name.isEmpty || target <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Vui lòng nhập tên và số tiền mục tiêu'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    if (existing == null) {
                      context.read<SavingGoalBloc>().add(AddSavingGoal(goalName: name, targetAmount: target, currentAmount: current, deadline: deadline));
                    } else {
                      context.read<SavingGoalBloc>().add(UpdateSavingGoal(id: existing.id, goalName: name, targetAmount: target, currentAmount: current, deadline: deadline, status: status));
                    }
                  },
                  style: AppWidgets.primaryButtonStyle(),
                  child: Text(existing == null ? 'Thêm mục tiêu' : 'Lưu thay đổi', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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
