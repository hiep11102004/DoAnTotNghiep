import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 👇 NHỚ KIỂM TRA LẠI ĐƯỜNG DẪN IMPORT NÀY CHO KHỚP VỚI MÁY ÔNG NHÉ
import '../bloc/aicoaching_bloc.dart';
import '../bloc/aicoaching_event.dart';
import '../bloc/aicoaching_state.dart';

class AiCoachingPage extends StatefulWidget {
  const AiCoachingPage({Key? key}) : super(key: key);

  @override
  State<AiCoachingPage> createState() => _AiCoachingPageState();
}

class _AiCoachingPageState extends State<AiCoachingPage> {
  @override
  void initState() {
    super.initState();
    // Bắn event gọi API Laravel khi vừa vào tab này
    context.read<AICoachingBloc>().add(LoadAICoachingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // Màu nền đồng bộ với Dashboard
      appBar: AppBar(
        title: const Text(
          'Trợ lý AI Coaching', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C3E50))
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Ẩn nút Back vì đang ở trong Navbar
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AICoachingBloc>().add(LoadAICoachingEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildDynamicAICoachingCard(), // Thẻ AI gắn Bloc
              const SizedBox(height: 16),
              _buildGamificationTasksCard(), // Thẻ nhiệm vụ của ông
              const SizedBox(height: 100), // Chừa không gian cho Navbar che khuất
            ],
          ),
        ),
      ),
    );
  }

  // THẺ AI ĐÃ ĐƯỢC GẮN BLOC ĐỂ HIỂN THỊ TEXT TỪ API LARAVEL
  Widget _buildDynamicAICoachingCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      builder: (context, state) {
        String displayText = "Đang kết nối để phân tích dữ liệu chi tiêu...";

        if (state is AICoachingLoading) {
          displayText = "AI đang đọc dữ liệu, đợi xíu nhé...";
        } else if (state is AICoachingLoaded) {
          displayText = state.coachingData.review; // Lấy câu văn thực tế từ cục JSON
        } else if (state is AICoachingError) {
          displayText = "Lỗi kết nối AI: ${state.message}";
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1F4068), Color(0xFF162447)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'AI FINANCIAL COACHING',
                    style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nếu đang Loading thì xoay tròn, nếu có chữ thì in chữ ra
              state is AICoachingLoading 
                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.amber)))
                : Text(
                    '"$displayText"',
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4, fontStyle: FontStyle.italic),
                  ),
            ],
          ),
        );
      },
    );
  }

  // BÊ NGUYÊN GIAO DIỆN TASK TỪ BÊN DASHBOARD CŨ SANG ĐÂY
  Widget _buildGamificationTasksCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.emoji_events_outlined, color: Colors.orange, size: 20),
                  SizedBox(width: 6),
                  Text('Thử thách tích lũy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                ],
              ),
              Text('1/2 Hoàn thành', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),
          _buildTaskItem('Ghi chép 1 giao dịch thu chi bất kỳ', true),
          const SizedBox(height: 8),
          _buildTaskItem('Xem nhận xét chi tiết từ Trợ lý AI', false),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskName, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? const Color(0xFF27AE60) : Colors.grey.shade300,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            taskName,
            style: TextStyle(
              fontSize: 12.5,
              color: isCompleted ? Colors.grey.shade500 : const Color(0xFF34495E),
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (!isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Text('+20 Exp', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}