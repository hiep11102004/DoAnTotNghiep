import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/core/constants/app_theme.dart';

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
    context.read<AICoachingBloc>().add(LoadAICoachingEvent());
    context.read<AICoachingBloc>().add(LoadAITasksEvent());
    context.read<AICoachingBloc>().add(LoadChallengesEvent());
    context.read<AICoachingBloc>().add(LoadBadgesEvent());
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AICoachingBloc, AICoachingState>(
        listenWhen: (_, s) => s is TaskCompleteSuccess || s is AITasksError,
        listener: (context, state) {
          if (state is TaskCompleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(state.message,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
              backgroundColor: AppColors.income,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ));
          }
        },
        child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<AICoachingBloc>().add(LoadAICoachingEvent());
          context.read<AICoachingBloc>().add(LoadAITasksEvent());
          context.read<AICoachingBloc>().add(LoadChallengesEvent());
          context.read<AICoachingBloc>().add(LoadBadgesEvent());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Page header ──
            SliverToBoxAdapter(child: _buildPageHeader()),
            // ── AI Review card (primary) ──
            SliverToBoxAdapter(child: _buildAIReviewCard()),
            // ── Detected Problems ──
            SliverToBoxAdapter(child: _buildProblemsCard()),
            // ── Recommendations ──
            SliverToBoxAdapter(child: _buildRecommendationsCard()),
            // ── Tasks (action-oriented) ──
            SliverToBoxAdapter(child: _buildAITasksCard()),
            // ── Challenges (motivation) ──
            SliverToBoxAdapter(child: _buildChallengesCard()),
            // ── Badges (achievement) ──
            SliverToBoxAdapter(child: _buildBadgesCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
        ),
    );
  }

  // ── Detected Problems ───────────────────────────────────────────────────────

  Widget _buildProblemsCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      buildWhen: (_, s) => s is AICoachingLoaded || s is AICoachingLoading,
      builder: (context, state) {
        if (state is! AICoachingLoaded) return const SizedBox.shrink();
        final problems = state.coachingData.detectedProblems;
        if (problems.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                  color: AppColors.expense.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.warning_amber_rounded,
                            color: AppColors.expense, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Vấn đề phát hiện',
                          style: AppTextStyles.h4
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                ...problems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final problem = entry.value;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: AppColors.expense,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(problem,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary, height: 1.4)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Recommendations ─────────────────────────────────────────────────────────

  Widget _buildRecommendationsCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      buildWhen: (_, s) => s is AICoachingLoaded || s is AICoachingLoading,
      builder: (context, state) {
        if (state is! AICoachingLoaded) return const SizedBox.shrink();
        final recs = state.coachingData.recommendations;
        if (recs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                  color: AppColors.income.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.income.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lightbulb_rounded,
                            color: AppColors.income, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Đề xuất hành động',
                          style: AppTextStyles.h4
                              .copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                ...recs.map((rec) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.income, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(rec,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Page header ────────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border:
            Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F4068), Color(0xFF162447)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.amber, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Coaching', style: AppTextStyles.h3),
              Text('Phân tích & tư vấn tài chính cá nhân',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  // ── AI Review card ─────────────────────────────────────────────────────────

  Widget _buildAIReviewCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F4068), Color(0xFF162447)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF162447).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome,
                              color: Colors.amber, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'AI FINANCIAL REVIEW',
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (state is AICoachingLoaded)
                      _buildScoreBadge(state.coachingData.financialScore),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: state is AICoachingLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.amber),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'AI đang phân tích chi tiêu của bạn...',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        '"${state is AICoachingLoaded ? state.coachingData.review : state is AICoachingError ? 'Không thể kết nối AI. Thử lại sau.' : 'Đang kết nối...'}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.55,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),

              // Health score bar (if loaded)
              if (state is AICoachingLoaded) ...[
                const SizedBox(height: AppSpacing.md),
                _buildHealthBar(state.coachingData.financialScore),
              ],

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBadge(int score) {
    Color c;
    if (score >= 80) c = const Color(0xFF2ECC71);
    else if (score >= 60) c = Colors.amber;
    else c = const Color(0xFFE74C3C);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(
        '$score điểm',
        style: TextStyle(
            color: c, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHealthBar(int score) {
    final ratio = (score / 100).clamp(0.0, 1.0);
    Color c;
    String label;
    if (score >= 80) {
      c = const Color(0xFF2ECC71);
      label = 'Sức khỏe tài chính: Tốt';
    } else if (score >= 60) {
      c = Colors.amber;
      label = 'Sức khỏe tài chính: Ổn';
    } else {
      c = const Color(0xFFE74C3C);
      label = 'Sức khỏe tài chính: Cần cải thiện';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6))),
              const Spacer(),
              Text('$score/100',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(c),
            ),
          ),
        ],
      ),
    );
  }

  // ── AI Tasks ───────────────────────────────────────────────────────────────

  Widget _buildAITasksCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      buildWhen: (_, curr) =>
          curr is AITasksLoading ||
          curr is AITasksLoaded ||
          curr is AITasksError,
      builder: (context, state) {
        if (state is AITasksLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state is AITasksError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text('Lỗi tải nhiệm vụ: ${state.message}',
                style:
                    const TextStyle(color: AppColors.expense, fontSize: 13)),
          );
        }
        if (state is AITasksLoaded) {
          final tasks = state.tasks;
          final completed = tasks.where((t) => t.isCompleted).length;
          final ratio =
              tasks.isNotEmpty ? completed / tasks.length : 0.0;

          return Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            decoration: AppWidgets.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(Icons.task_alt_rounded,
                            color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                          child: Text('Nhiệm vụ hôm nay',
                              style: AppTextStyles.h4)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: completed == tasks.length
                              ? AppColors.primaryLight
                              : AppColors.background,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '$completed/${tasks.length}',
                          style: AppTextStyles.caption.copyWith(
                              color: completed == tasks.length
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.divider),
                // Task list
                ...tasks.map((task) => _buildTaskRow(task)),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTaskRow(dynamic task) {
    return InkWell(
      onTap: task.isCompleted
          ? null
          : () => context
              .read<AICoachingBloc>()
              .add(CompleteAITaskEvent(task.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              task.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  task.isCompleted ? AppColors.income : AppColors.border,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                task.title,
                style: AppTextStyles.body.copyWith(
                  color: task.isCompleted
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            if (!task.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('+${task.exp} XP',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  // ── Challenges ─────────────────────────────────────────────────────────────

  Widget _buildChallengesCard() {
    return BlocConsumer<AICoachingBloc, AICoachingState>(
      listenWhen: (_, curr) =>
          curr is ChallengeActionSuccess || curr is ChallengesError,
      listener: (context, state) {
        if (state is ChallengeActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.income,
              behavior: SnackBarBehavior.floating));
        } else if (state is ChallengesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.expense,
              behavior: SnackBarBehavior.floating));
        }
      },
      buildWhen: (_, curr) =>
          curr is ChallengesLoading ||
          curr is ChallengesLoaded ||
          curr is ChallengesError,
      builder: (context, state) {
        if (state is ChallengesLoading) return const SizedBox.shrink();
        if (state is! ChallengesLoaded || state.challenges.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          decoration: AppWidgets.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                          Icons.emoji_events_outlined,
                          color: AppColors.warning,
                          size: 16),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Thử thách đang diễn ra',
                        style: AppTextStyles.h4),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ...state.challenges.map((c) => _buildChallengeRow(c)),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengeRow(dynamic c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.warning.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(c.description, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.warning),
                      const SizedBox(width: 3),
                      Text('+${c.rewardPoints} điểm',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: () => context
                  .read<AICoachingBloc>()
                  .add(JoinChallengeEvent(c.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Tham gia',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badges ─────────────────────────────────────────────────────────────────

  Widget _buildBadgesCard() {
    return BlocBuilder<AICoachingBloc, AICoachingState>(
      buildWhen: (_, s) =>
          s is BadgesLoading || s is BadgesLoaded || s is BadgesError,
      builder: (context, state) {
        if (state is BadgesLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state is BadgesError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text(state.message,
                style: const TextStyle(
                    color: AppColors.expense, fontSize: 13)),
          );
        }
        if (state is BadgesLoaded) {
          if (state.badges.isEmpty) {
            return Container(
              margin: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppWidgets.cardDecoration(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md)),
                    child: const Icon(Icons.military_tech_rounded,
                        color: AppColors.warning, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Huy hiệu của tôi', style: AppTextStyles.h4),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                            'Chưa có huy hiệu. Hoàn thành nhiệm vụ để nhận!',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
            decoration: AppWidgets.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm)),
                        child: const Icon(Icons.military_tech_rounded,
                            color: AppColors.warning, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                          'Huy hiệu của tôi (${state.badges.length})',
                          style: AppTextStyles.h4),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: state.badges
                        .map((b) => _buildBadgeChip(b))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBadgeChip(dynamic badge) {
    return Container(
      width: 88,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.warning.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            Border.all(color: AppColors.warning.withOpacity(0.25), width: 1),
      ),
      child: Column(
        children: [
          badge.iconUrl != null
              ? Image.network(
                  badge.iconUrl!,
                  width: 34,
                  height: 34,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.warning,
                      size: 34),
                )
              : const Icon(Icons.military_tech_rounded,
                  color: AppColors.warning, size: 34),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('+${badge.xpReward} XP',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
