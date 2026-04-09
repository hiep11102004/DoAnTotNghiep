<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    // 1. Lấy danh sách giao dịch của người dùng
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Lấy giao dịch thông qua các ví của User đó
        $transactions = Transaction::whereHas('wallet', function($query) use ($user) {
            $query->where('user_id', $user->id);
        })->with(['category', 'wallet'])->orderBy('date', 'desc')->get();

        return response()->json($transactions);
    }

    // 2. Thêm giao dịch mới và cập nhật số dư ví
    public function store(Request $request)
    {
        $request->validate([
            'wallet_id' => 'required|exists:wallets,id',
            'category_id' => 'required|exists:categories,id',
            'amount' => 'required|numeric|min:0',
            'type' => 'required|in:Thu,Chi', // Xác định loại để cộng hay trừ tiền
            'date' => 'required|date',
        ]);

        // Dùng DB Transaction để đảm bảo: Hoặc cả 2 cùng thành công, hoặc không cái nào cả
        return DB::transaction(function () use ($request) {
            $wallet = Wallet::findOrFail($request->wallet_id);

            // Tạo giao dịch
            $transaction = Transaction::create($request->all());

            // Cập nhật số dư ví
            if ($request->type === 'Chi') {
                $wallet->current_balance -= $request->amount;
            } else {
                $wallet->current_balance += $request->amount;
            }
            $wallet->save();

            return response()->json([
                'message' => 'Lưu giao dịch thành công!',
                'transaction' => $transaction->load(['category', 'wallet']),
                'new_balance' => $wallet->current_balance
            ], 201);
        });
    }

    // app/Http/Controllers/Api/TransactionController.php

    // 3. Xem chi tiết 1 giao dịch
    public function show($id)
    {
        return Transaction::with(['category', 'wallet'])->findOrFail($id);
    }

    // 4. Cập nhật giao dịch (Ví dụ sửa số tiền)
    public function update(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);
        $wallet = Wallet::findOrFail($transaction->wallet_id);

        return DB::transaction(function () use ($request, $transaction, $wallet) {
            // Hoàn tác số tiền cũ trong ví trước khi cập nhật
            if ($transaction->type === 'Chi') {
                $wallet->current_balance += $transaction->amount;
            } else {
                $wallet->current_balance -= $transaction->amount;
            }
            // Cập nhật dữ liệu mới
            $transaction->update($request->all());

            // Áp dụng số tiền mới vào ví
            if ($request->type === 'Chi') {
                $wallet->current_balance -= $request->amount;
            } else {
                $wallet->current_balance += $request->amount;
            }
        
            $wallet->save();
            return response()->json(['message' => 'Cập nhật thành công', 'transaction' => $transaction]);
        });
    }

    // 5. Xóa giao dịch (Và hoàn tiền vào ví)
    public function destroy($id)
    {
        $transaction = Transaction::findOrFail($id);
        $wallet = Wallet::findOrFail($transaction->wallet_id);

        DB::transaction(function () use ($transaction, $wallet) {
            if ($transaction->type === 'Chi') {
                $wallet->current_balance += $transaction->amount; // Hoàn tiền chi
            } else {
                $wallet->current_balance -= $transaction->amount; // Trừ tiền thu
            }
            $wallet->save();
            $transaction->delete();
        });
        return response()->json(['message' => 'Đã xóa giao dịch và cập nhật lại ví']);
    }
}