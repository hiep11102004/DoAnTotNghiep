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

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  State<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  bool _isIncome = false; 
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  int? _selectedWalletId; 
  int? _selectedCategoryId; // 🛠️ ĐÃ XÓA GIÁ TRỊ GÁN CỨNG (=1)

  // 🛠️ ĐÃ XÓA BỎ MẢNG _categories GÁN CỨNG Ở ĐÂY!
  
  final ImagePicker _picker = ImagePicker();
  XFile? _receiptImage;
  bool _isScanningAI = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 🚀 Hàm tự động gắn Icon đẹp cho Danh mục dựa vào tên
  IconData _getIconForCategory(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ăn')) return Icons.fastfood;
    if (lowerName.contains('lại') || lowerName.contains('xe')) return Icons.directions_car;
    if (lowerName.contains('mua')) return Icons.shopping_bag;
    if (lowerName.contains('lương')) return Icons.attach_money;
    if (lowerName.contains('hóa đơn')) return Icons.receipt_long;
    if (lowerName.contains('khỏe') || lowerName.contains('thuốc')) return Icons.medical_services;
    return Icons.category; // Icon mặc định
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF27AE60)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
                title: const Text('Chọn ảnh từ Thư viện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF27AE60)),
                title: const Text('Chụp ảnh hóa đơn mới'),
                onTap: () {
                  Navigator.of(context).pop();
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
          model: 'gemini-1.5-flash', 
          apiKey: '', 
        );

        final prompt = '''
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
          String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
          final data = jsonDecode(cleanJson);

          setState(() {
            _amountController.text = data['amount'].toString();
            _noteController.text = data['note'].toString();
            _isScanningAI = false;
          });
        }
      } catch (e) {
        setState(() => _isScanningAI = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI lỗi: $e')));
      }
    }
  }

  void _submitTransaction() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ!'), backgroundColor: Colors.red));
      return;
    }

    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn Ví và Danh mục!'), backgroundColor: Colors.red));
      return;
    }

    final dateString = "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} 12:00:00";

    context.read<TransactionBloc>().add(
      AddTransactionSubmitted(
        walletId: _selectedWalletId!,      
        categoryId: _selectedCategoryId!,  
        amount: amount,
        type: _isIncome ? 'Thu' : 'Chi',
        date: dateString,
        note: _noteController.text.isNotEmpty ? _noteController.text : 'Giao dịch mới',
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: bottomInset + 20),
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
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isScanningAI ? null : _showImageSourceActionSheet,
                icon: _isScanningAI ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.document_scanner, color: Colors.blueAccent),
                label: Text(_isScanningAI ? 'AI đang phân tích ảnh...' : '✨ Quét hóa đơn bằng AI', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue.shade50,
                ),
              ),
            ),
            
            if (_receiptImage != null && !_isScanningAI) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Đã đính kèm: ${_receiptImage!.name}', style: const TextStyle(fontSize: 12, color: Colors.green), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
            
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isIncome = false;
                        _selectedCategoryId = null; // 🚀 BÍ QUYẾT: Reset chọn mục khi đổi sang Chi
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: !_isIncome ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: !_isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : []),
                        alignment: Alignment.center,
                        child: Text('Tiền ra (Chi)', style: TextStyle(fontWeight: FontWeight.bold, color: !_isIncome ? const Color(0xFFE74C3C) : Colors.grey.shade500)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isIncome = true;
                        _selectedCategoryId = null; // 🚀 BÍ QUYẾT: Reset chọn mục khi đổi sang Thu
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: _isIncome ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: _isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : []),
                        alignment: Alignment.center,
                        child: Text('Tiền vào (Thu)', style: TextStyle(fontWeight: FontWeight.bold, color: _isIncome ? const Color(0xFF27AE60) : Colors.grey.shade500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                List<dynamic> walletsList = [];
                if (state is WalletLoaded) {
                  walletsList = state.wallets;
                  if (_selectedWalletId == null && walletsList.isNotEmpty) {
                    _selectedWalletId = walletsList.first.id;
                  }
                }

                return DropdownButtonFormField<int>(
                  value: _selectedWalletId,
                  decoration: InputDecoration(
                    labelText: 'Chọn Ví',
                    prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF27AE60)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: walletsList.map((wallet) {
                    return DropdownMenuItem<int>(
                      value: wallet.id,
                      child: Text(wallet.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedWalletId = value),
                );
              },
            ),
            const SizedBox(height: 16),

            // 🚀 ĐÃ NÂNG CẤP: DÙNG CATEGORY BLOC + LỌC DATA TỪ ENTITY
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  // Lọc: Nếu _isIncome = true thì lấy type "income", ngược lại lấy "expense"
                  final targetType = _isIncome ? 'income' : 'expense';
                  final filteredCategories = state.categories.where((cat) => cat.type == targetType).toList();

                  // Tự động gán ID hợp lệ đầu tiên nếu chưa chọn
                  if (_selectedCategoryId == null && filteredCategories.isNotEmpty) {
                    _selectedCategoryId = filteredCategories.first.id;
                  } else if (!filteredCategories.any((cat) => cat.id == _selectedCategoryId) && filteredCategories.isNotEmpty) {
                    _selectedCategoryId = filteredCategories.first.id;
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Chọn Danh mục',
                      prefixIcon: Icon(_isIncome ? Icons.account_balance : Icons.category, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: filteredCategories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id, // 🛠️ Dùng thuộc tính của Entity
                        child: Row(
                          children: [
                            Icon(_getIconForCategory(category.name), color: Colors.blueGrey, size: 20),
                            const SizedBox(width: 12),
                            Text(category.name), // 🛠️ Dùng thuộc tính của Entity
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                  );
                } else {
                  return const Text('Chưa tải được danh mục.');
                }
              },
            ),
            const SizedBox(height: 20),

            Text('SỐ TIỀN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _isIncome ? const Color(0xFF27AE60) : const Color(0xFFE74C3C)),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                suffixText: 'đ',
                suffixStyle: const TextStyle(fontSize: 24, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            Divider(color: Colors.grey.shade200),
            
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.notes, color: Colors.grey.shade400, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: 'Thêm ghi chú (Ăn trưa, đổ xăng...)', border: InputBorder.none),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade200),

            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 16, color: Colors.black87))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitTransaction,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: const Text('Lưu giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}