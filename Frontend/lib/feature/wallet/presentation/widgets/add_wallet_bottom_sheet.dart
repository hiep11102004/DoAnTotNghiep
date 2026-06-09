import 'package:financial_app/feature/wallet/data/models/wallet_model.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:financial_app/feature/wallet/presentation/bloc/wallet_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_theme.dart';

class AddWalletBottomSheet extends StatefulWidget {
  final WalletModel? walletToEdit;

  const AddWalletBottomSheet({super.key, this.walletToEdit});

  @override
  State<AddWalletBottomSheet> createState() => _AddWalletBottomSheetState();
}

class _AddWalletBottomSheetState extends State<AddWalletBottomSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  bool get _isEditMode => widget.walletToEdit != null;

  // Wallet type is display-only (CreateWallet event doesn't support it yet)
  int _selectedTypeIndex = 0;

  @override
  void initState() {
    super.initState();
    final existing = widget.walletToEdit;
    if (existing != null) {
      _nameController.text = existing.name;
      _balanceController.text = existing.currentBalance.toStringAsFixed(0);
    }
  }

  static const _walletTypes = [
    {'label': 'Tiền mặt', 'icon': Icons.payments_rounded, 'color': Color(0xFF27AE60)},
    {'label': 'Ngân hàng', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF2980B9)},
    {'label': 'Ví điện tử', 'icon': Icons.phone_android_rounded, 'color': Color(0xFF8E44AD)},
    {'label': 'Khác', 'icon': Icons.more_horiz_rounded, 'color': Color(0xFF7F8C8D)},
  ];

  // ── Business logic (unchanged) ─────────────────────────────────────────────

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitData() {
    final name = _nameController.text.trim();
    final balance =
        double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng nhập tên ví'),
          behavior: SnackBarBehavior.floating));
      return;
    }

    final bloc = context.read<WalletBloc>();
    if (_isEditMode) {
      bloc.add(UpdateWallet(id: widget.walletToEdit!.id, name: name));
    } else {
      bloc.add(CreateWallet(name: name, initialBalance: balance));
    }
    Navigator.of(context).pop(true);
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  String get _previewName {
    final n = _nameController.text.trim();
    return n.isEmpty ? 'Tên ví' : n;
  }

  double get _previewBalance {
    return double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;
  }

  String _formatCurrency(double amount) {
    return amount
            .toStringAsFixed(0)
            .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},') +
        ' đ';
  }

  Color get _typeColor =>
      _walletTypes[_selectedTypeIndex]['color'] as Color;

  IconData get _typeIcon =>
      _walletTypes[_selectedTypeIndex]['icon'] as IconData;

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
                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_isEditMode ? 'Sửa ví' : 'Thêm ví mới',
                          style: AppTextStyles.h3),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Live preview card ──
                  _buildPreviewCard(),
                  const SizedBox(height: 20),

                  if (!_isEditMode) ...[
                    Text('LOẠI VÍ',
                        style: AppTextStyles.label
                            .copyWith(letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    _buildTypeSelector(),
                    const SizedBox(height: 16),
                  ],

                  // ── Name field ──
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.bodyLarge,
                    onChanged: (_) => setState(() {}),
                    decoration: AppWidgets.inputDecoration(
                      label: 'Tên ví (VD: Tiền mặt, Vietcombank...)',
                      prefixIcon: Icon(Icons.account_balance_wallet_rounded,
                          color: _typeColor, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isEditMode) ...[
                    TextField(
                      controller: _balanceController,
                      readOnly: true,
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary),
                      decoration: AppWidgets.inputDecoration(
                        label: 'Số dư hiện tại (không sửa tại đây)',
                        prefixIcon: const Icon(Icons.monetization_on_rounded,
                            color: AppColors.textSecondary, size: 20),
                        suffixText: 'đ',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Số dư thay đổi qua giao dịch thu/chi.',
                      style: AppTextStyles.caption,
                    ),
                  ] else ...[
                    TextField(
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.bodyLarge,
                      onChanged: (_) => setState(() {}),
                      decoration: AppWidgets.inputDecoration(
                        label: 'Số dư ban đầu',
                        prefixIcon: const Icon(Icons.monetization_on_rounded,
                            color: AppColors.primary, size: 20),
                        suffixText: 'đ',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Submit ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: AppWidgets.primaryButtonStyle(),
                      child: Text(_isEditMode ? 'Lưu thay đổi' : 'Tạo ví',
                          style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_typeColor, _typeColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _previewName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Icon(_typeIcon, color: Colors.white.withOpacity(0.8), size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'SỐ DƯ',
            style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.65),
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(_previewBalance),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: List.generate(_walletTypes.length, (i) {
        final type = _walletTypes[i];
        final isSelected = _selectedTypeIndex == i;
        final color = type['color'] as Color;
        final icon = type['icon'] as IconData;
        final label = type['label'] as String;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTypeIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < _walletTypes.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      size: 20,
                      color: isSelected ? color : AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
