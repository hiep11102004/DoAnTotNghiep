import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

// Đổi đường dẫn này cho khớp với thư mục của ông nhé
import '../bloc/report_bloc.dart'; 
import '../../data/models/category_spending_model.dart'; 

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Biến này để lưu xem người dùng đang chạm vào "miếng bánh" nào
  int touchedIndex = -1; 

  // Hàm chuyển mã màu Hex từ Backend (vd: #27AE60) sang Color của Flutter
  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    try {
      return Color(int.parse('0x$hexColor'));
    } catch (e) {
      return Colors.grey; // Nếu lỗi mã màu thì mặc định là màu xám
    }
  }

  // Hàm format tiền tệ (có dấu phẩy)
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    ) + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text(
          'Báo cáo chi tiêu', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ReportLoaded) {
            final list = state.spendingList;
            
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có chi tiêu nào trong tháng này.', 
                  style: TextStyle(color: Colors.grey)
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  
                  // 1. BIỂU ĐỒ PIE CHART
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40, // Khoảng trống ở giữa biểu đồ
                        sections: _showingSections(list),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 2. DANH SÁCH CHÚ THÍCH (LEGEND)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03), 
                          blurRadius: 10, 
                          offset: const Offset(0, 4)
                        )
                      ],
                    ),
                    child: Column(
                      children: list.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _parseColor(item.colorHex),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.categoryName,
                                  style: const TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w600, 
                                    color: Color(0xFF2C3E50)
                                  ),
                                ),
                              ),
                              Text(
                                _formatCurrency(item.totalAmount),
                                style: const TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold, 
                                  color: Color(0xFFE74C3C)
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          
          if (state is ReportError) {
            return Center(
              child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red))
            );
          }
          
          return const SizedBox();
        },
      ),
    );
  }

  // Hàm tạo các "miếng bánh" cho biểu đồ
  List<PieChartSectionData> _showingSections(List<CategorySpendingModel> list) {
    // Tính tổng tiền để chia %
    double total = 0;
    for (var item in list) {
      total += item.totalAmount;
    }

    return List.generate(list.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0; // Phóng to nếu được chạm vào
      final item = list[i];
      
      // Tính phần trăm để hiện lên chữ
      final percentage = (item.totalAmount / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: _parseColor(item.colorHex),
        value: item.totalAmount,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }
}