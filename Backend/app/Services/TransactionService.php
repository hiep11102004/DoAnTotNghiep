<?php
namespace App\Services;

use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\Budget;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;
use App\Services\GamificationService;

class TransactionService
{
    // Lấy danh sách giao dịch của User
    public function getAllTransactions($user)
    {
        return Transaction::whereHas('wallet', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })->with(['category', 'wallet'])->orderBy('date', 'desc')->get();
    }

    // Xem chi tiết
    public function getTransactionById($id)
    {
        return Transaction::with(['category', 'wallet'])->findOrFail($id);
    }

    // THÊM MỚI (Đã có logic Ngân sách & Điểm)
    public function createTransaction(array $data, $userId)
    {
        return DB::transaction(function () use ($data, $userId) {
            $transaction = Transaction::create($data);
            $this->updateWalletBalance($data['wallet_id'], $data['amount'], $data['type'], 'plus');
            
            if ($data['type'] === 'Chi') {
                $this->handleBudgetLogic($userId, $data['category_id']);
            }
            $gamificationService = new GamificationService();
            $gamificationService->addPoints($userId, 10);

            return $transaction;
        });
    }

    // CẬP NHẬT (Phải hoàn tác tiền cũ, áp dụng tiền mới)
    public function updateTransaction($id, array $newData, $userId)
    {
        return DB::transaction(function () use ($id, $newData, $userId) {
            $transaction = Transaction::findOrFail($id);
            
            // 1. Hoàn tác số tiền cũ trong ví
            $this->updateWalletBalance($transaction->wallet_id, $transaction->amount, $transaction->type, 'minus');

            // 2. Cập nhật dữ liệu mới vào DB
            $transaction->update($newData);

            // 3. Áp dụng số tiền mới vào ví
            $this->updateWalletBalance($transaction->wallet_id, $transaction->amount, $transaction->type, 'plus');

            // 4. Cập nhật lại ngân sách
            if ($transaction->type === 'Chi') {
                $this->handleBudgetLogic($userId, $transaction->category_id);
            }

            return $transaction;
        });
    }

    // XÓA (Phải hoàn tiền lại cho ví)
    public function deleteTransaction($id, $userId)
    {
        return DB::transaction(function () use ($id, $userId) {
            $transaction = Transaction::findOrFail($id);
            
            // Hoàn tiền lại cho ví
            $this->updateWalletBalance($transaction->wallet_id, $transaction->amount, $transaction->type, 'minus');
            
            $categoryId = $transaction->category_id;
            $transaction->delete();

            // Cập nhật lại ngân sách sau khi xóa
            $this->handleBudgetLogic($userId, $categoryId);
            
            return true;
        });
    }

    // Hàm phụ dùng chung để cập nhật số dư ví
    private function updateWalletBalance($walletId, $amount, $type, $action)
    {
        $wallet = Wallet::findOrFail($walletId);
        
        // $action = 'plus' là áp dụng giao dịch, 'minus' là hoàn tác (undo)
        if ($action === 'plus') {
            ($type === 'Chi') ? $wallet->current_balance -= $amount : $wallet->current_balance += $amount;
        } else {
            ($type === 'Chi') ? $wallet->current_balance += $amount : $wallet->current_balance -= $amount;
        }
        
        $wallet->save();
    }

    // Logic Ngân sách (Tách riêng để tái sử dụng)
    private function handleBudgetLogic($userId, $categoryId)
    {
        $budget = Budget::where('user_id', $userId)
        ->where('category_id', $categoryId)
        ->whereMonth('start_date', now()->month)
        ->first();

    if ($budget) {
        // 1. Tính tổng đã tiêu trong tháng của danh mục này
        $totalSpent = Transaction::whereHas('wallet', function($q) use ($userId) {
                $q->where('user_id', $userId);
            })
            ->where('category_id', $categoryId)
            ->whereMonth('date', now()->month)
            ->where('type', 'Chi')
            ->sum('amount');

        // 2. Cập nhật số tiền đã tiêu vào bảng Budgets
        $budget->update(['spent_amount' => $totalSpent]);

        // 3. KIỂM TRA NGƯỠNG CẢNH BÁO
        // alert_threshold lưu dạng integer (e.g. 80 = 80%), phải chia 100 khi tính
        $limit = $budget->amount_limit;
        $threshold = $budget->alert_threshold;

        if ($totalSpent >= ($limit * $threshold / 100)) {
            // Kiểm tra xem đã báo trong hôm nay chưa để tránh spam
            $exists = Notification::where('user_id', $userId)
                ->where('type', 'budget_alert')
                ->where('title', 'like', '%' . $budget->category->name . '%')
                ->whereDate('created_at', now()->today())
                ->exists();

            if (!$exists) {
                Notification::create([
                    'user_id' => $userId,
                    'title' => "Cảnh báo ngân sách {$budget->category->name}!",
                    'message' => "Bạn đã tiêu " . number_format($totalSpent) . "đ, đạt " . ($totalSpent/$limit * 100) . "% hạn mức.",
                    'type' => 'budget_alert',
                    'is_read' => false
                ]);
            }
        }
    }
    }

    private function handleGamification($userId)
    {
        User::find($userId)->increment('total_points', 10);
    }
}