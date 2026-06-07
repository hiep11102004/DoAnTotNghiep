import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_event.dart';
import 'package:financial_app/feature/category/presentation/bloc/category_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_event.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:financial_app/core/constants/app_secrets.dart';
import 'package:financial_app/core/constants/app_theme.dart';

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  bool _isIncome = false;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  int? _selectedWalletId;
  int? _selectedCategoryId;

  final ImagePicker _picker = ImagePicker();
  XFile? _receiptImage;
  bool _isScanningAI = false;

  // ── Business logic (unchanged) ─────────────────────────────────────────────

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  IconData _getIconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('ăn') || n.contains('uống')) return Icons.restaurant_rounded;
    if (n.contains('di chuyển') || n.contains('xe') || n.contains('xăng')) return Icons.directions_car_rounded;
    if (n.contains('mua sắm')) return Icons.shopping_bag_rounded;
    if (n.contains('giải trí') || n.contains('phim')) return Icons.movie_rounded;
    if (n.contains('hóa đơn') || n.contains('tiện ích')) return Icons.receipt_long_rounded;
    if (n.contains('sức khỏe') || n.contains('y tế')) return Icons.medical_services_rounded;
    if (n.contains('giáo dục') || n.contains('học')) return Icons.school_rounded;
    if (n.contains('tiền nhà') || n.contains('thuê') || n.contains('trọ')) return Icons.home_rounded;
    if (n.contains('du lịch')) return Icons.flight_rounded;
    if (n.contains('quần áo') || n.contains('thời trang')) return Icons.checkroom_rounded;
    if (n.contains('làm đẹp') || n.contains('spa')) return Icons.spa_rounded;
    if (n.contains('gia dụng')) return Icons.chair_rounded;
    if (n.contains('thể thao') || n.contains('gym')) return Icons.fitness_center_rounded;
    if (n.contains('quà')) return Icons.card_giftcard_rounded;
    if (n.contains('tiết kiệm') || n.contains('đầu tư') || n.contains('lãi')) return Icons.savings_rounded;
    if (n.contains('phí ngân hàng')) return Icons.account_balance_rounded;
    if (n.contains('bảo hiểm')) return Icons.security_rounded;
    if (n.contains('lương')) return Icons.payments_rounded;
    if (n.contains('thưởng')) return Icons.emoji_events_rounded;
    if (n.contains('freelance') || n.contains('làm thêm')) return Icons.laptop_rounded;
    if (n.contains('kinh doanh')) return Icons.store_rounded;
    if (n.contains('hoàn tiền') || n.contains('bồi thường')) return Icons.replay_rounded;
    return Icons.label_rounded;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
                title: const Text('Chọn ảnh từ Thư viện'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Chụp ảnh hóa đơn mới'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _isScanningAI = true;
        _receiptImage = pickedFile;
      });
      try {
        final imageBytes = await pickedFile.readAsBytes();
        final model = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: AppSecrets.geminiApiKey,
        );
        const prompt = '''
          Hãy đóng vai một hệ thống nhận diện hóa đơn chuyên nghiệp. Phân tích bức ảnh này.
          NẾU BỨC ẢNH KHÔNG PHẢI LÀ HÓA ĐƠN HOẶC KHÔNG CÓ SỐ TIỀN: Bắt buộc trả về JSON này: {"amount": "0", "note": "Không nhận diện được hóa đơn"}
          NẾU LÀ HÓA ĐƠN THẬT, trích xuất:
          1. Tổng số tiền phải thanh toán cuối cùng.
          2. Tên cửa hàng hoặc lý do chi tiêu ngắn gọn.
          BẮT BUỘC TRẢ VỀ ĐÚNG ĐỊNH DẠNG JSON SAU: {"amount": "tổng_số_tiền", "note": "tên_cửa_hàng"}
        ''';
        final response = await model.generateContent([
          Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
        ]);
        if (response.text != null) {
          String cleanJson =
              response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
          final data = jsonDecode(cleanJson);
          setState(() {
            _amountController.text = data['amount'].toString();
            _noteController.text = data['note'].toString();
            _isScanningAI = false;
          });
        }
      } catch (e) {
        setState(() => _isScanningAI = false);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('AI lỗi: $e')));
        }
      }
    }
  }

  void _submitTransaction() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ!'),
          backgroundColor: Colors.red));
      return;
    }
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng chọn Ví và Danh mục!'),
          backgroundColor: Colors.red));
      return;
    }

    final dateString =
        "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} 12:00:00";

    context.read<TransactionBloc>().add(
          AddTransactionSubmitted(
            walletId: _selectedWalletId!,
            categoryId: _selectedCategoryId!,
            amount: amount,
            type: _isIncome ? 'Thu' : 'Chi',
            date: dateString,
            note: _noteController.text.isNotEmpty
                ? _noteController.text
                : 'Giao dịch mới',
            status: 'Hoàn thành',
          ),
        );

    final walletBloc = context.read<WalletBloc>();
    final budgetBloc = context.read<BudgetBloc>();
    Navigator.pop(context, true);

    Future.delayed(const Duration(milliseconds: 600), () {
      walletBloc.add(const FetchWallets());
      budgetBloc.add(FetchBudgets());
    });
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Color get _typeColor => _isIncome ? AppColors.income : AppColors.expense;
  Color get _typeBg => _isIncome ? AppColors.incomeBg : AppColors.expenseBg;

  String _formatDate(DateTime d) {
    const weekdays = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(d.year, d.month, d.day);
    if (selected == today) return 'Hôm nay, ${d.day}/${d.month}/${d.year}';
    if (selected == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${d.day}/${d.month}/${d.year}';
    }
    return '${weekdays[d.weekday]}, ${d.day}/${d.month}/${d.year}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thêm giao dịch', style: AppTextStyles.h3),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Type toggle ──
                  _buildTypeToggle(),
                  const SizedBox(height: 20),

                  // ── Amount card ──
                  _buildAmountCard(),
                  const SizedBox(height: 16),

                  // ── Wallet + Date row ──
                  _buildDetailsCard(),
                  const SizedBox(height: 16),

                  // ── Category grid ──
                  _buildCategorySection(),
                  const SizedBox(height: 16),

                  // ── Note ──
                  _buildNoteField(),
                  const SizedBox(height: 16),

                  // ── AI Scan (secondary) ──
                  _buildAIScanButton(),
                  const SizedBox(height: 20),

                  // ── Submit ──
                  _buildSubmitButton(),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTypeBtn(isIncome: false)),
          const SizedBox(width: 4),
          Expanded(child: _buildTypeBtn(isIncome: true)),
        ],
      ),
    );
  }

  Widget _buildTypeBtn({required bool isIncome}) {
    final isSelected = _isIncome == isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final bg = isIncome ? AppColors.incomeBg : AppColors.expenseBg;
    final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final label = isIncome ? 'Thu nhập' : 'Chi tiêu';

    return GestureDetector(
      onTap: () => setState(() {
        _isIncome = isIncome;
        _selectedCategoryId = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? bg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: _typeBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _typeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SỐ TIỀN',
            style: AppTextStyles.label.copyWith(
              color: _typeColor.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: _typeColor,
                    letterSpacing: -0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: _typeColor.withOpacity(0.25),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Text(
                'đ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _typeColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Wallet row
          BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              List<dynamic> walletsList = [];
              if (state is WalletLoaded) {
                walletsList = state.wallets;
                if (_selectedWalletId == null && walletsList.isNotEmpty) {
                  _selectedWalletId = walletsList.first.id;
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonFormField<int>(
                  value: _selectedWalletId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.primary, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  hint: const Text('Chọn ví',
                      style: TextStyle(color: AppColors.textHint)),
                  items: walletsList.map((w) {
                    return DropdownMenuItem<int>(
                      value: w.id,
                      child: Text(w.name, style: AppTextStyles.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedWalletId = v),
                ),
              );
            },
          ),
          Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
          // Date row
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate),
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is! CategoryLoaded) {
          return Text('Không tải được danh mục',
              style: AppTextStyles.bodySmall);
        }

        final targetType = _isIncome ? 'income' : 'expense';
        final categories =
            state.categories.where((c) => c.type == targetType).toList();

        if (!categories.any((c) => c.id == _selectedCategoryId)) {
          _selectedCategoryId = null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DANH MỤC',
              style: AppTextStyles.label.copyWith(letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategoryId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _typeColor.withOpacity(0.12)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? _typeColor
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconForCategory(cat.name),
                          size: 15,
                          color: isSelected
                              ? _typeColor
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? _typeColor
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.notes_rounded,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _noteController,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Thêm ghi chú...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIScanButton() {
    return OutlinedButton.icon(
      onPressed: _isScanningAI ? null : _showImageSourceActionSheet,
      icon: _isScanningAI
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.blueAccent))
          : const Icon(Icons.document_scanner_rounded,
              size: 16, color: Colors.blueAccent),
      label: Text(
        _isScanningAI ? 'AI đang phân tích...' : 'Quét hóa đơn bằng AI',
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: const BorderSide(color: Colors.blueAccent, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.blue.shade50,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _typeColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          _isIncome ? 'Lưu Thu nhập' : 'Lưu Chi tiêu',
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}
