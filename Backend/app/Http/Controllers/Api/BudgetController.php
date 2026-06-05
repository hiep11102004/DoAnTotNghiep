<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Budget;

class BudgetController extends Controller
{
    /**
     * Lấy danh sách ngân sách của user đang đăng nhập
     */
    public function index(Request $request)
    {
        // 🛠️ Không gán cứng: Chỉ lấy ngân sách của user hiện tại
        $budgets = Budget::where('user_id', $request->user()->id)->get();
        return response()->json($budgets);
    }

    /**
     * Tạo ngân sách mới
     */
    public function store(Request $request)
    {
        // 🚀 BÍ QUYẾT FIX LỖI: Hứng cả 'amount' hoặc 'amount_limit' từ Flutter gửi lên
        $receivedAmount = $request->input('amount_limit') ?? $request->input('amount');
        
        // Gắn ngược lại vào request để validate
        $request->merge(['amount_limit' => $receivedAmount]);

        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'amount_limit' => 'required|numeric|min:0', // Phải dùng amount_limit cho khớp Database
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'alert_threshold' => 'nullable|numeric',
        ]);

        // 🛠️ Không gán cứng: Gán user_id tự động từ Token
        $budget = Budget::create([
            'user_id' => $request->user()->id,
            'category_id' => $validated['category_id'],
            'amount_limit' => $validated['amount_limit'], // Lưu đúng tên cột
            'spent_amount' => 0, // Mới tạo thì tiêu = 0
            'start_date' => $validated['start_date'],
            'end_date' => $validated['end_date'],
            'alert_threshold' => $validated['alert_threshold'] ?? 80, // Mặc định cảnh báo khi tiêu hết 80%
        ]);

        return response()->json($budget, 201);
    }

    /**
     * Xem chi tiết ngân sách
     */
    public function show(Request $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->findOrFail($id);
        return response()->json($budget);
    }

    /**
     * Cập nhật ngân sách
     */
    public function update(Request $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->findOrFail($id);

        $receivedAmount = $request->input('amount_limit') ?? $request->input('amount');
        if ($receivedAmount !== null) {
            $request->merge(['amount_limit' => $receivedAmount]);
        }

        $validated = $request->validate([
            'category_id' => 'exists:categories,id',
            'amount_limit' => 'numeric|min:0',
            'start_date' => 'date',
            'end_date' => 'date|after_or_equal:start_date',
            'alert_threshold' => 'nullable|numeric',
        ]);

        $budget->update($validated);
        return response()->json($budget);
    }

    /**
     * Xóa ngân sách
     */
    public function destroy(Request $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->findOrFail($id);
        $budget->delete();
        return response()->json(['message' => 'Đã xóa ngân sách thành công']);
    }
}