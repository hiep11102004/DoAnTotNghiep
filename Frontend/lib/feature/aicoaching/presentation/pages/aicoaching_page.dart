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
    context.read<AICoachingBloc>().add(LoadAITasksEvent());
    context.read<AICoachingBloc>().add(LoadChallengesEvent());
    context.read<AICoachingBloc>().add(LoadBadgesEvent());
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
          context.read<AICoachingBloc>().add(LoadAITasksEvent());
          context.read<AICoachingBloc>().add(LoadChallengesEvent());
          context.read<AICoachingBloc>().add(LoadBadgesEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildDynamicAICoachingCard(), // Thẻ AI gắn Bloc
              const SizedBox(height: 16),
              _buildAITasksCard(),
              const SizedBox(height: 16),
              _buildChallengesCard(),
              const SizedBox(height: 16),
              _buildBadgesCard(),
              const SizedBox(height: 100),
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

  Widget _buildAITasksCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      buildWhen: (prev, curr) => curr is AITasksLoading || curr is AITasksLoaded || curr is AITasksError,
      builder: (context, state) {
        if (state is AITasksLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        if (state is AITasksError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Lỗi tải nhiệm vụ: ${state.message}', style: const TextStyle(color: Colors.red)),
          );
        }
        if (state is AITasksLoaded) {
          final tasks = state.tasks;
          final completed = tasks.where((t) => t.isCompleted).length;
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
                    const Row(children: [
                      Icon(Icons.task_alt, color: Colors.orange, size: 20),
                      SizedBox(width: 6),
                      Text('Nhiệm vụ hôm nay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                    ]),
                    Text('$completed/${tasks.length} Xong', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 10),
                ...tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: task.isCompleted ? null : () => context.read<AICoachingBloc>().add(CompleteAITaskEvent(task.id)),
                        child: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: task.isCompleted ? const Color(0xFF27AE60) : Colors.grey.shade300,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(task.title, style: TextStyle(
                          fontSize: 13,
                          color: task.isCompleted ? Colors.grey.shade500 : const Color(0xFF34495E),
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        )),
                      ),
                      if (!task.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                          child: Text('+${task.exp} Exp', style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildChallengesCard() {
    return BlocConsumer<AICoachingBloc, AICoachingState>(
      listenWhen: (_, curr) => curr is ChallengeActionSuccess || curr is ChallengesError,
      listener: (context, state) {
        if (state is ChallengeActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
        } else if (state is ChallengesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      buildWhen: (_, curr) => curr is ChallengesLoading || curr is ChallengesLoaded || curr is ChallengesError,
      builder: (context, state) {
        if (state is ChallengesLoading) return const SizedBox();
        if (state is ChallengesLoaded) {
          if (state.challenges.isEmpty) return const SizedBox();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 20),
                  SizedBox(width: 6),
                  Text('Thử thách đang diễn ra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                ]),
                const SizedBox(height: 12),
                ...state.challenges.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50))),
                            const SizedBox(height: 4),
                            Text(c.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            const SizedBox(height: 4),
                            Text('+${c.rewardPoints} điểm', style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.read<AICoachingBloc>().add(JoinChallengeEvent(c.id)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Tham gia', style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBadgesCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      buildWhen: (_, s) => s is BadgesLoading || s is BadgesLoaded || s is BadgesError,
      builder: (context, state) {
        if (state is BadgesLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is BadgesError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 12)),
          );
        }
        if (state is BadgesLoaded) {
          if (state.badges.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Huy hiệu của tôi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF2C3E50))),
                        const SizedBox(height: 4),
                        Text('Chưa có huy hiệu nào. Hoàn thành nhiệm vụ để nhận huy hiệu!', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.amber.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('Huy hiệu của tôi (${state.badges.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: state.badges.map((b) => _buildBadgeItem(b)).toList(),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBadgeItem(dynamic badge) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
          badge.iconUrl != null
              ? Image.network(badge.iconUrl!, width: 36, height: 36, errorBuilder: (_, __, ___) => const Icon(Icons.military_tech, color: Colors.amber, size: 36))
              : const Icon(Icons.military_tech, color: Colors.amber, size: 36),
          const SizedBox(height: 6),
          Text(badge.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('+${badge.xpReward} XP', style: const TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}