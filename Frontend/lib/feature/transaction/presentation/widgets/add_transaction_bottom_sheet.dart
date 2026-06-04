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

  // 🛠️ ĐÃ THÊM: Biến lưu ID được chọn
  int? _selectedWalletId = 2; // Mặc định chọn ví số 2 (Tài khoản ngân hàng)
  int? _selectedCategoryId = 1; // Mặc định chọn danh mục 1 (Ăn uống)

  // 🛠️ ĐÃ THÊM: Danh sách Ví giả lập
  final List<Map<String, dynamic>> _wallets = [
    {'id': 1, 'name': 'Ví tiền mặt'},
    {'id': 2, 'name': 'Tài khoản ngân hàng'},
  ];

  // 🛠️ ĐÃ THÊM: Danh sách Danh mục giả lập (Để vẽ biểu đồ nhiều màu)
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'id': 2, 'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': Colors.blue},
    {'id': 3, 'name': 'Giải trí', 'icon': Icons.movie, 'color': Colors.purple},
    {'id': 4, 'name': 'Đi lại', 'icon': Icons.directions_car, 'color': Colors.green},
  ];
  
  // Biến quản lý ImagePicker và file ảnh
  final ImagePicker _picker = ImagePicker();
  XFile? _receiptImage;
  bool _isScanningAI = false;

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
      });

      try {
        final imageBytes = await pickedFile.readAsBytes();

        final model = GenerativeModel(
          model: 'gemini-3.5-flash', 
          apiKey: '', 
        );

        final prompt = '''
          Hãy đóng vai một hệ thống nhận diện hóa đơn chuyên nghiệp. Phân tích bức ảnh này.
          
          NẾU BỨC ẢNH KHÔNG PHẢI LÀ HÓA ĐƠN HOẶC KHÔNG CÓ SỐ TIỀN:
          Bắt buộc trả về đúng JSON này: {"amount": "0", "note": "Không nhận diện được hóa đơn"}
          
          NẾU LÀ HÓA ĐƠN THẬT, hãy trích xuất:
          1. Tổng số tiền phải thanh toán cuối cùng (chỉ trả về các con số, ví dụ: 150000. Không chứa dấu phẩy, chữ đ hay VNĐ).
          2. Tên cửa hàng hoặc lý do chi tiêu ngắn gọn.
          
          BẮT BUỘC TRẢ VỀ ĐÚNG ĐỊNH DẠNG JSON SAU, KHÔNG GIẢI THÍCH HAY VIẾT THÊM BẤT CỨ CHỮ NÀO KHÁC:
          {"amount": "tổng_số_tiền", "note": "tên_cửa_hàng"}
        ''';

        final response = await model.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ])
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
        setState(() {
          _isScanningAI = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI không thể đọc được hóa đơn: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _submitTransaction() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ!'), backgroundColor: Colors.red),
      );
      return;
    }

    // 🛠️ ĐÃ THÊM: Chặn lưu nếu quên chọn Ví hoặc Danh mục
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Ví và Danh mục!'), backgroundColor: Colors.red),
      );
      return;
    }

    final dateString = "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} 12:00:00";

    context.read<TransactionBloc>().add(
      AddTransactionSubmitted(
        walletId: _selectedWalletId!,      // 👈 Truyền ID thật vào đây
        categoryId: _selectedCategoryId!,  // 👈 Truyền ID thật vào đây
        amount: amount,
        type: _isIncome ? 'Thu' : 'Chi',
        date: dateString,
        note: _noteController.text.isNotEmpty ? _noteController.text : 'Giao dịch mới',
        status: 'Hoàn thành',
      ),
    );

    Navigator.pop(context, true);
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
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isScanningAI ? null : _showImageSourceActionSheet,
                icon: _isScanningAI 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.document_scanner, color: Colors.blueAccent),
                label: Text(
                  _isScanningAI ? 'AI đang phân tích ảnh...' : '✨ Quét hóa đơn bằng AI',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
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
                  Expanded(
                    child: Text(
                      'Đã đính kèm: ${_receiptImage!.name}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                      onTap: () => setState(() => _isIncome = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isIncome ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: !_isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tiền ra (Chi)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: !_isIncome ? const Color(0xFFE74C3C) : Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isIncome ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tiền vào (Thu)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _isIncome ? const Color(0xFF27AE60) : Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🛠️ ĐÃ THÊM: Giao diện Dropdown chọn Ví
            DropdownButtonFormField<int>(
              value: _selectedWalletId,
              decoration: InputDecoration(
                labelText: 'Chọn Ví',
                prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF27AE60)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _wallets.map((wallet) {
                return DropdownMenuItem<int>(
                  value: wallet['id'],
                  child: Text(wallet['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedWalletId = value),
            ),
            const SizedBox(height: 16),

            // 🛠️ ĐÃ THÊM: Giao diện Dropdown chọn Danh mục
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Chọn Danh mục',
                prefixIcon: const Icon(Icons.category, color: Colors.blueAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Row(
                    children: [
                      Icon(category['icon'], color: category['color'], size: 20),
                      const SizedBox(width: 12),
                      Text(category['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
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
                    decoration: const InputDecoration(
                      hintText: 'Thêm ghi chú (Ăn trưa, đổ xăng...)',
                      border: InputBorder.none,
                    ),
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
                  Expanded(
                    child: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Lưu giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}