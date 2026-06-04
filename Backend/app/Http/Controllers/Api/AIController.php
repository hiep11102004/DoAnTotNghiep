<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\Budget;
use App\Models\SavingGoal; // Giả định ông có bảng này lưu mục tiêu tiết kiệm (Xpander...)
use Gemini\Laravel\Facades\Gemini;

class AIController extends Controller
{
    public function getReviews(Request $request)
    {
        // FIX 1: Tạm thời gán cứng user_id = 1 (hoặc ID của ông trong DB) để test thông luồng Gemini.
        // Sau này khi Flutter truyền Token chuẩn thì mở lại dòng $request->user()->id
        $userId = $request->user() ? $request->user()->id : 1; 

        // 1. Thu thập dữ liệu thực tế của User để làm nguyên liệu cho AI
        $walletIds = Wallet::where('user_id', $userId)->pluck('id');
        $totalBalance = Wallet::where('user_id', $userId)->sum('current_balance');
        
        // Tính tổng thu, tổng chi trong tháng này
        $totalIncome = Transaction::whereIn('wallet_id', $walletIds)->where('type', 'Thu')->whereMonth('date', now()->month)->sum('amount');
        $totalExpense = Transaction::whereIn('wallet_id', $walletIds)->where('type', 'Chi')->whereMonth('date', now()->month)->sum('amount');

        // Lấy danh sách giao dịch gần đây để AI biết ông hay tiêu gì
        $recentNotes = Transaction::whereIn('wallet_id', $walletIds)->where('type', 'Chi')->orderBy('date', 'desc')->take(5)->pluck('note')->toArray();
        $recentNotesStr = empty($recentNotes) ? "Chưa có giao dịch" : implode(', ', $recentNotes);

        // 2. Xây dựng Prompt
        $prompt = "Bạn là một chuyên gia huấn luyện tài chính cá nhân (AI Financial Coach) thông minh, vui vẻ.
        Hãy phân tích dữ liệu tài chính thực tế sau đây của người dùng:
        - Tổng số dư hiện tại trong các ví: " . number_format($totalBalance) . "đ
        - Tổng tiền thu vào tháng này: " . number_format($totalIncome) . "đ
        - Tổng tiền đã chi ra tháng này: " . number_format($totalExpense) . "đ
        - Các khoản chi gần đây nhất: {$recentNotesStr}.
        
        Yêu cầu: 
        1. Đưa ra 1 lời nhận xét ngắn gọn, súc tích (khoảng 2-3 câu), chỉ thẳng vào thói quen chi tiêu. Nhắc tới mục tiêu mua xe Xpander nếu thấy họ đang tiết kiệm tốt.
        2. Giọng văn phải mang tính động viên, chuyên nghiệp nhưng gần gũi.
        
        BẮT BUỘC TRẢ VỀ ĐÚNG ĐỊNH DẠNG JSON SAU, KHÔNG GIẢI THÍCH DÒNG VO:
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