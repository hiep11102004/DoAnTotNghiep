<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AI_Review;
use App\Models\AI_Task;
use Illuminate\Http\Request;

class AIController extends Controller
{
    // Lấy danh sách các lời khuyên AI đã từng đưa ra
    public function getReviews(Request $request)
    {
        $reviews = AI_Review::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json($reviews);
    }

    // Lấy danh sách nhiệm vụ mà AI giao cho người dùng
    public function getTasks(Request $request)
    {
        // Lấy task của Review mới nhất
        $tasks = AI_Task::whereHas('aiReview', function($q) use ($request) {
            $q->where('user_id', $request->user()->id);
        })->where('status', 'pending')->get();
        
        return response()->json($tasks);
    }

    // Người dùng tích chọn hoàn thành nhiệm vụ AI giao
    public function completeTask(Request $request, $id)
    {
        $task = AI_Task::findOrFail($id);
        $task->update(['status' => 'completed']);
        
        // Bonus: Khi hoàn thành task AI thì cộng 20 điểm Gamification
        $user = $request->user();
        $user->increment('total_points', 20);

        return response()->json(['message' => 'Nhiệm vụ hoàn thành! Bạn được +20 điểm']);
    }
}