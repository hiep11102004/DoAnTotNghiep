<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBudgetRequest;
use App\Http\Requests\UpdateBudgetRequest;
use App\Http\Resources\BudgetResource;
use Illuminate\Http\Request;
use App\Models\Budget;

class BudgetController extends Controller
{
    /**
     * Lấy danh sách ngân sách của user đang đăng nhập
     */
    public function index(Request $request)
    {
        $budgets = Budget::where('user_id', $request->user()->id)
            ->with('category')
            ->get();
        return response()->json(BudgetResource::collection($budgets));
    }

    /**
     * Tạo ngân sách mới
     */
    public function store(StoreBudgetRequest $request)
    {
        $validated = $request->validated();

        $budget = Budget::create([
            'user_id'         => $request->user()->id,
            'category_id'     => $validated['category_id'],
            'amount_limit'    => $validated['amount_limit'],
            'spent_amount'    => 0,
            'start_date'      => $validated['start_date'],
            'end_date'        => $validated['end_date'],
            'alert_threshold' => $validated['alert_threshold'] ?? 80,
        ]);

        return response()->json(new BudgetResource($budget->load('category')), 201);
    }

    /**
     * Xem chi tiết ngân sách
     */
    public function show(Request $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->with('category')->findOrFail($id);
        return response()->json(new BudgetResource($budget));
    }

    /**
     * Cập nhật ngân sách
     */
    public function update(UpdateBudgetRequest $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->with('category')->findOrFail($id);
        $budget->update($request->validated());
        return response()->json(new BudgetResource($budget->load('category')));
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