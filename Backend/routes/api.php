<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\AIController;
use App\Http\Controllers\Api\GamificationController;
// THÊM 3 IMPORT CÒN THIẾU NÀY VÀO (Không có là lỗi 500 ngay):
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\SavingGoalController;
use App\Http\Controllers\Api\NotificationController;

/*
|--------------------------------------------------------------------------
| PUBLIC ROUTES (Không cần Token)
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (Bắt buộc phải có Token qua Sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    
    // 1. Quản lý User & Profile
    Route::get('/user', function (Request $request) { return $request->user(); });
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/user/settings', [AuthController::class, 'updateSettings']);

    // 2. Quản lý Ví (Wallets)
    Route::apiResource('wallets', WalletController::class);

    // 3. Quản lý Danh mục (Categories)
    Route::apiResource('categories', CategoryController::class); // Tối ưu thành apiResource luôn cho nhàn

    // 4. Quản lý Thu chi (Transactions) - Dùng Service
    // LƯU Ý CỰC KỲ QUAN TRỌNG: Các route custom (như /summary) PHẢI ĐẶT TRƯỚC apiResource!
    Route::get('/transactions/summary', [TransactionController::class, 'getSummary']); 
    Route::apiResource('transactions', TransactionController::class); // 1 Dòng này thay thế cho 5 dòng index, store, show, update, destroy cũ của ông.

    // 5. Ngân sách & Tiết kiệm (Budgets & Saving Goals)
    Route::apiResource('budgets', BudgetController::class);
    Route::apiResource('saving-goals', SavingGoalController::class);

    // 6. Trí tuệ nhân tạo (AI Coaching)
    Route::get('/ai/reviews', [AIController::class, 'getReviews']);
    Route::get('/ai/tasks', [AIController::class, 'getTasks']);
    Route::post('/ai/tasks/{id}/complete', [AIController::class, 'completeTask']);

    // 7. Gamification (Badges & Challenges)
    Route::get('/badges', [GamificationController::class, 'getMyBadges']);
    Route::get('/challenges', [GamificationController::class, 'index']);
    Route::post('/challenges/{id}/join', [GamificationController::class, 'joinChallenge']);

    // 8. Thông báo (Notifications)
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
});