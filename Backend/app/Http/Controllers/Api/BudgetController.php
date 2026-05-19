<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Budget;

class BudgetController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $budgets = Budget::where('user_id', $request->user()->id)
            ->whereMonth('start_date', now()->month)
            ->with('category')
            ->get();
        return response()->json($budgets);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'amount_limit' => 'required|numeric|min:0',
            'alert_threshold' => 'nullable|numeric|min:0|max:1', // Ví dụ: 0.8 (80%)
        ]);

        // Sử dụng updateOrCreate để tránh một danh mục có 2 ngân sách trong 1 tháng
        $budget = Budget::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'category_id' => $validated['category_id'],
                'start_date' => now()->startOfMonth(),
            ],
            [
                'amount_limit' => $validated['amount_limit'],
                'alert_threshold' => $validated['alert_threshold'] ?? 0.8,
                'end_date' => now()->endOfMonth(),
            ]
        );

        return response()->json([
            'message' => 'Thiết lập ngân sách thành công',
            'data' => $budget
        ]);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->findOrFail($id);
        return response()->json($budget);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->findOrFail($id);

        $validated = $request->validate([
            'amount_limit' => 'numeric|min:0',
            'alert_threshold' => 'nullable|numeric|min:0|max:1',
        ]);

        $budget->update($validated);

        return response()->json($budget);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)->findOrFail($id);
        $budget->delete();

        return response()->json(['message' => 'Ngân sách đã được xóa']);
    }
}
