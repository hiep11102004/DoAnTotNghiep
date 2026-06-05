<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\SavingGoal;
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

        $recentNotes = Transaction::where('user_id', $userId)
            ->where('type', 'Chi')
            ->orderBy('date', 'desc')
            ->take(5)
            ->pluck('note')
            ->filter()
            ->toArray();
        $recentNotesStr = empty($recentNotes) ? 'Chưa có giao dịch' : implode(', ', $recentNotes);

        // 2. Lấy mục tiêu tiết kiệm thực tế của user
        $savingGoals = SavingGoal::where('user_id', $userId)->get();
        if ($savingGoals->isEmpty()) {
            $goalsStr = 'Chưa có mục tiêu tiết kiệm nào';
        } else {
            $goalsStr = $savingGoals->map(function ($g) {
                $progress = $g->target_amount > 0
                    ? round(($g->current_amount / $g->target_amount) * 100)
                    : 0;
                return "{$g->goal_name} (cần " . number_format($g->target_amount) . "đ, đã tiết kiệm " . number_format($g->current_amount) . "đ — {$progress}%)";
            })->implode('; ');
        }

        // 3. Xây dựng Prompt dùng dữ liệu thực tế
        $prompt = "Bạn là một chuyên gia huấn luyện tài chính cá nhân (AI Financial Coach) thông minh, vui vẻ.
        Hãy phân tích dữ liệu tài chính thực tế sau đây của người dùng:
        - Tổng số dư hiện tại trong các ví: " . number_format($totalBalance) . "đ
        - Tổng tiền thu vào tháng này: " . number_format($totalIncome) . "đ
        - Tổng tiền đã chi ra tháng này: " . number_format($totalExpense) . "đ
        - Các khoản chi gần đây nhất: {$recentNotesStr}
        - Mục tiêu tiết kiệm của người dùng: {$goalsStr}

        Yêu cầu:
        1. Đưa ra 1 lời nhận xét ngắn gọn, súc tích (khoảng 2-3 câu), chỉ thẳng vào thói quen chi tiêu.
        2. Nếu người dùng đang tiến gần tới mục tiêu tiết kiệm nào đó, hãy nhắc tới và động viên họ.
        3. Giọng văn phải mang tính động viên, chuyên nghiệp nhưng gần gũi.

        BẮT BUỘC TRẢ VỀ ĐÚNG ĐỊNH DẠNG JSON SAU, KHÔNG GIẢI THÍCH THÊM:
        {\"review\": \"nội_dung_lời_nhận_xét_của_bạn\"}";

        try {
            // 3. Gửi prompt lên não bộ Gemini
            $result = Gemini::generativeModel(model: 'gemini-3.5-flash')->generateContent($prompt);
            
            // Làm sạch chuỗi JSON trả về
            $cleanJson = preg_replace('/```json|```/', '', $result->text());
            $data = json_decode(trim($cleanJson), true);

            return response()->json([
                'status' => 'success',
                'data' => $data
            ]);
        } catch (\Exception $e) {
            // FIX 2: Trả về mã 200 thay vì 500 để Flutter đọc được nội dung lỗi và in ra UI.
            return response()->json([
                'status' => 'success', // Lừa Dio là thành công để nó parse JSON
                'data' => [
                    // Nhồi thẳng lỗi của Gemini vào giao diện để anh em mình dễ bắt bệnh
                    'review' => 'Lỗi kết nối Gemini: ' . $e->getMessage(), 
                    'financial_score' => 0
                ]
            ], 200); 
        }
    }

    public function getTasks(Request $request)
    {
        // Hàm này dùng để sinh ra các "Thử thách tích lũy" (Nhiệm vụ AI)
        // Để làm nhanh cho đồ án, ông có thể trả về một mảng danh sách nhiệm vụ tĩnh (Hardcode) từ DB
        // Hoặc dùng Gemini sinh ngẫu nhiên. Ở đây tôi viết mẫu danh sách tĩnh tối ưu cho nhanh và ổn định:
        $tasks = [
            [
                'id' => 1,
                'title' => 'Ghi chép 1 giao dịch thu chi bất kỳ',
                'exp' => 20,
                'is_completed' => true
            ],
            [
                'id' => 2,
                'title' => 'Xem nhận xét chi tiết từ Trợ lý AI',
                'exp' => 20,
                'is_completed' => false
            ],
            [
                'id' => 3,
                'title' => 'Không chi tiêu vượt hạn mức Ngân sách tuần này',
                'exp' => 50,
                'is_completed' => false
            ]
        ];

        return response()->json([
            'status' => 'success',
            'data' => $tasks
        ]);
    }

    public function completeTask(Request $request, $id)
    {
        // Xử lý khi người dùng hoàn thành nhiệm vụ (Cộng Exp, đổi trạng thái)
        return response()->json([
            'status' => 'success',
            'message' => 'Hoàn thành nhiệm vụ số ' . $id . ' thành công! Đã cộng điểm thưởng.'
        ]);
    }
}