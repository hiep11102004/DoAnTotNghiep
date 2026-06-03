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
  
  // 🛠️ ĐÃ THÊM: Biến quản lý ImagePicker và file ảnh
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

  // 🛠️ HÀM MỚI: Hiện bảng tùy chọn chụp ảnh hoặc lấy từ thư viện
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

  // 🛠️ HÀM MỚI: Xử lý lấy ảnh và gọi giả lập AI
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _isScanningAI = true;
      });

      try {
        // 1. Đọc file ảnh thành dữ liệu byte
        final imageBytes = await pickedFile.readAsBytes();

        // 2. Khởi tạo não bộ Gemini (DÁN API KEY CỦA ÔNG VÀO ĐÂY)
        // Lưu ý: Sau này làm đồ án thật thì nên giấu Key này vào file .env nhé
        final model = GenerativeModel(
          model: 'gemini-3.5-flash', // Dùng bản Flash cho tốc độ xử lý ảnh cực nhanh
          apiKey: '', 
        );

        // 3. Ra lệnh cho AI bằng Prompt (Dặn nó trả về JSON cho dễ đọc)
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

        // 4. Bắn ảnh và câu lệnh lên Google
        final response = await model.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ]);

        // 5. Bóc tách kết quả JSON AI trả về và điền vào Form
        if (response.text != null) {
          // Xóa các ký tự thừa (như ```json và ```) nếu AI lỡ tay thêm vào
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
        // Báo lỗi nếu AI không đọc được
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

    final dateString = "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} 12:00:00";

    context.read<TransactionBloc>().add(
      AddTransactionSubmitted(
        walletId: 1, 
        categoryId: 1, 
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

            // NÚT GỌI AI QUÉT HÓA ĐƠN ĐÃ NỐI VỚI HÀM CHỌN ẢNH
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                // Bấm vào nút này sẽ gọi hàm _showImageSourceActionSheet mở menu Thư viện/Camera
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
            
            // 🛠️ HÀM MỚI: Nếu có ảnh thì hiển thị trạng thái tên file cho chuyên nghiệp
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