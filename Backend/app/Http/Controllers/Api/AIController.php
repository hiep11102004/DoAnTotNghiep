<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\SavingGoal;
use App\Models\AIReview;
use App\Models\AITask;
use App\Models\User;
use App\Services\GamificationService;
use Gemini\Laravel\Facades\Gemini;

class AIController extends Controller
{
    public function getReviews(Request $request)
    {
        $userId = $request->user()->id;

        // 1. Thu thập dữ liệu tài chính của user
        $totalBalance = Wallet::where('user_id', $userId)->sum('current_balance');
        $totalIncome  = Transaction::where('user_id', $userId)->where('type', 'Thu')->whereMonth('date', now()->month)->sum('amount');
        $totalExpense = Transaction::where('user_id', $userId)->where('type', 'Chi')->whereMonth('date', now()->month)->sum('amount');

        // Chi tiêu theo danh mục — prefix bảng để tránh ambiguous sau JOIN
        $expenseByCategory = Transaction::query()
            ->join('categories', 'transactions.category_id', '=', 'categories.id')
            ->where('transactions.user_id', $userId)
            ->where('transactions.type', 'Chi')
            ->whereMonth('transactions.date', now()->month)
            ->selectRaw('categories.name as category_name, SUM(transactions.amount) as total')
            ->groupBy('categories.name')
            ->orderByDesc('total')
            ->take(5)
            ->get();

        $categoryBreakdown = $expenseByCategory->isEmpty()
            ? 'Chưa có dữ liệu chi tiêu theo danh mục'
            : $expenseByCategory->map(fn($c) =>
                "{$c->category_name}: " . number_format($c->total) . "đ"
              )->implode(', ');

        // Ngày cuối cùng có giao dịch tiết kiệm
        $lastSavingDate = Transaction::where('user_id', $userId)
            ->where('type', 'Thu')
            ->latest('date')
            ->value('date');
        $daysSinceSaving = $lastSavingDate
            ? now()->diffInDays($lastSavingDate)
            : 999;

        // Mục tiêu tiết kiệm
        $savingGoals = SavingGoal::where('user_id', $userId)->get();
        $goalsStr = $savingGoals->isEmpty()
            ? 'Chưa có mục tiêu tiết kiệm nào'
            : $savingGoals->map(function ($g) {
                $progress = $g->target_amount > 0
                    ? round(($g->current_amount / $g->target_amount) * 100)
                    : 0;
                return "{$g->goal_name} (cần " . number_format($g->target_amount) . "đ, đã có " . number_format($g->current_amount) . "đ — {$progress}%)";
            })->implode('; ');

        // 2. Xây dựng prompt mới — yêu cầu phân tích + đề xuất + nhiệm vụ
        $savingsRate = $totalIncome > 0
            ? round((($totalIncome - $totalExpense) / $totalIncome) * 100)
            : 0;

        $prompt = "Bạn là AI Financial Coach chuyên nghiệp cho ứng dụng quản lý tài chính cá nhân.
Phân tích dữ liệu tài chính tháng này của người dùng và tạo ra kế hoạch hành động cụ thể.

DỮ LIỆU TÀI CHÍNH:
- Tổng số dư: " . number_format($totalBalance) . "đ
- Thu nhập tháng này: " . number_format($totalIncome) . "đ
- Chi tiêu tháng này: " . number_format($totalExpense) . "đ
- Tỷ lệ tiết kiệm: {$savingsRate}%
- Chi tiêu theo danh mục: {$categoryBreakdown}
- Số ngày kể từ lần thu nhập gần nhất: {$daysSinceSaving} ngày
- Mục tiêu tiết kiệm: {$goalsStr}

YÊU CẦU OUTPUT (JSON nghiêm ngặt, không giải thích thêm):
{
  \"review\": \"Nhận xét tổng quan 2-3 câu, giọng chuyên nghiệp và động viên\",
  \"financial_score\": <số nguyên 0-100, đánh giá sức khỏe tài chính>,
  \"detected_problems\": [\"Vấn đề 1 ngắn gọn\", \"Vấn đề 2 ngắn gọn\"],
  \"recommendations\": [\"Giải pháp cụ thể 1\", \"Giải pháp cụ thể 2\"],
  \"tasks\": [
    {\"title\": \"Tên nhiệm vụ cụ thể, có thể đo lường\", \"xp\": <20|50|100>, \"deadline_days\": <3|7|14>},
    {\"title\": \"Nhiệm vụ 2\", \"xp\": <20|50|100>, \"deadline_days\": <3|7|14>},
    {\"title\": \"Nhiệm vụ 3\", \"xp\": <20|50|100>, \"deadline_days\": <3|7|14>}
  ]
}

QUY TẮC:
- detected_problems: tối đa 3 vấn đề quan trọng nhất
- recommendations: 1 giải pháp ứng với mỗi vấn đề
- tasks: đúng 3 nhiệm vụ, XP 20=dễ, 50=trung bình, 100=khó
- Nếu chi tiêu < thu nhập và tỷ lệ tiết kiệm > 20%: financial_score >= 75
- Nếu chi tiêu > thu nhập: financial_score <= 40
- Nhiệm vụ phải liên quan trực tiếp đến vấn đề đã phát hiện";

        try {
            $result = Gemini::generativeModel(model: 'gemini-2.5-flash-lite')->generateContent($prompt);

            $cleanJson = preg_replace('/```json|```/', '', $result->text());
            $data = json_decode(trim($cleanJson), true);

            if (!$data || !isset($data['review'])) {
                throw new \Exception('Gemini trả về JSON không hợp lệ');
            }

            // 3. Lưu vào ai_reviews + tạo ai_tasks trong DB
            DB::transaction(function () use ($userId, $data) {
                // Tạo review mới (mỗi lần gọi = 1 review mới)
                $review = AIReview::create([
                    'user_id'               => $userId,
                    'content'               => $data['review'],
                    'review_type'           => 'Tháng',
                    'financial_health_score'=> min(100, max(0, $data['financial_score'] ?? 50)),
                    'forecast_data'         => [
                        'detected_problems'  => $data['detected_problems'] ?? [],
                        'recommendations'    => $data['recommendations'] ?? [],
                    ],
                ]);

                // Tạo các nhiệm vụ liên kết với review này
                foreach (($data['tasks'] ?? []) as $task) {
                    // Validate XP: chỉ cho phép 20, 50 hoặc 100
                    $xp = in_array($task['xp'] ?? 20, [20, 50, 100])
                        ? $task['xp']
                        : 20;
                    $deadlineDays = min(30, max(1, $task['deadline_days'] ?? 7));

                    AITask::create([
                        'review_id'     => $review->id,
                        'task_name'     => $task['title'] ?? 'Nhiệm vụ tài chính',
                        'description'   => $task['title'] ?? '',
                        'points_reward' => $xp,
                        'deadline'      => now()->addDays($deadlineDays),
                        'status'        => 'Chưa làm',
                    ]);
                }
            });

            return response()->json([
                'status' => 'success',
                'data'   => [
                    'review'             => $data['review'],
                    'financial_score'    => min(100, max(0, $data['financial_score'] ?? 50)),
                    'detected_problems'  => $data['detected_problems'] ?? [],
                    'recommendations'    => $data['recommendations'] ?? [],
                    'tasks'              => $data['tasks'] ?? [],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'success',
                'data'   => [
                    'review'            => 'Lỗi kết nối Gemini: ' . $e->getMessage(),
                    'financial_score'   => 0,
                    'detected_problems' => [],
                    'recommendations'   => [],
                    'tasks'             => [],
                ],
            ], 200);
        }
    }

    public function getTasks(Request $request)
    {
        $userId = $request->user()->id;

        // Lấy tasks từ review mới nhất của user
        $latestReview = AIReview::where('user_id', $userId)
            ->latest()
            ->first();

        if (!$latestReview) {
            return response()->json(['status' => 'success', 'data' => []]);
        }

        $tasks = AITask::where('review_id', $latestReview->id)
            ->get()
            ->map(fn($t) => [
                'id'           => $t->id,
                'title'        => $t->task_name,
                'exp'          => $t->points_reward,
                'is_completed' => $t->status === 'Hoàn thành',
                'deadline'     => $t->deadline?->toDateString(),
            ]);

        return response()->json(['status' => 'success', 'data' => $tasks]);
    }

    public function completeTask(Request $request, $id)
    {
        $userId = $request->user()->id;

        // Tìm task và verify thuộc review của user
        $task = AITask::whereHas('review', fn($q) => $q->where('user_id', $userId))
            ->where('id', $id)
            ->first();

        if (!$task) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy nhiệm vụ'], 404);
        }

        if ($task->status === 'Hoàn thành') {
            return response()->json(['status' => 'error', 'message' => 'Nhiệm vụ này đã hoàn thành rồi'], 400);
        }

        DB::transaction(function () use ($task, $userId) {
            // Cập nhật trạng thái task
            $task->update([
                'status'       => 'Hoàn thành',
                'completed_at' => now(),
            ]);

            // Cộng XP cho user
            $gamification = new GamificationService();
            $gamification->addPoints($userId, $task->points_reward);
        });

        return response()->json([
            'status'  => 'success',
            'message' => "Hoàn thành nhiệm vụ! +{$task->points_reward} XP",
            'xp'      => $task->points_reward,
        ]);
    }
}
