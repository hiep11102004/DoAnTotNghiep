import 'package:flutter/material.dart';

class AddBudgetBottomSheet extends StatefulWidget {
  const AddBudgetBottomSheet({super.key});

  @override
  State<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends State<AddBudgetBottomSheet> {
  final _limitController = TextEditingController();
  
  // 🛠️ BIẾN LƯU TRỮ ID ĐƯỢC CHỌN TỪ DROPDOWN
  int? _selectedCategoryId;

  // 🛠️ DANH SÁCH CÁC DANH MỤC CỐ ĐỊNH (Tương ứng với ID trên Laravel)
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Ăn uống 🍔', 'icon': Icons.fastfood, 'color': Colors.orange},
    {'id': 2, 'name': 'Đi lại 🚗', 'icon': Icons.directions_car, 'color': Colors.blue},
    {'id': 3, 'name': 'Mua sắm 🛍️', 'icon': Icons.shopping_bag, 'color': Colors.pink},
    {'id': 4, 'name': 'Giải trí 🎬', 'icon': Icons.movie, 'color': Colors.purple},
    {'id': 5, 'name': 'Hóa đơn 🧾', 'icon': Icons.receipt_long, 'color': Colors.amber},
    {'id': 6, 'name': 'Sức khỏe 💊', 'icon': Icons.medical_services, 'color': Colors.teal},
  ];

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục ngân sách!')));
      return;
    }

    final limit = double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0;
    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hạn mức phải lớn hơn 0!')));
      return;
    }

    // Gửi Event tạo ngân sách mới lên BLoC (Ông nhớ check lại event của ông tên gì nhé)
    // context.read<BudgetBloc>().add(CreateBudget(categoryId: _selectedCategoryId!, limit: limit));
    
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thiết lập ngân sách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 20),
          
          // 🛠️ DROPDOWN MENU CHỌN DANH MỤC NGÂN SÁCH
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Chọn danh mục',
              prefixIcon: const Icon(Icons.category_rounded, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            hint: const Text('VD: Ăn uống, Đi lại...'),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            items: _categories.map((cat) {
              return DropdownMenuItem<int>(
                value: cat['id'],
                child: Row(
                  children: [
                    Icon(cat['icon'], size: 18, color: cat['color']),
                    const SizedBox(width: 10),
                    Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Ô NHẬP HẠN MỨC TIỀN
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Hạn mức tối đa / tháng',
              prefixIcon: const Icon(Icons.monetization_on_rounded, color: Colors.green),
              suffixText: 'đ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // NÚT LƯU
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Lưu Ngân Sách', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}