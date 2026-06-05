<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\TransactionService;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Models\Budget;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    protected $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    // public function index(Request $request)
    // {
    //     // $transactions = $this->transactionService->getAllTransactions($request->user());
    //     // return response()->json($transactions);
    //     $mockUser = \App\Models\User::find(1); 
        
    //     $transactions = $this->transactionService->getAllTransactions($mockUser);
    //     return response()->json($transactions);
    // }

    public function index(Request $request)
    {
        // 1. Tìm tất cả các ID ví thuộc về user đang đăng nhập
        $walletIds = \App\Models\Wallet::where('user_id', $request->user()->id)->pluck('id');

        // 2. Lấy tất cả giao dịch nằm trong các ví đó (sắp xếp mới nhất lên đầu)
        $transactions = Transaction::whereIn('wallet_id', $walletIds)
                                   ->orderBy('date', 'desc')
                                   ->orderBy('id', 'desc')
                                   ->get();

        // 3. Trả về đúng cấu trúc mà App Flutter đang mong đợi
        return response()->json([
            'data' => $transactions
        ]);
    }

    public function store(Request $request)
    {
        // 1. Validate dữ liệu đầu vào cho chắc cú
        $validated = $request->validate([
            'wallet_id' => 'required|exists:wallets,id',
            'category_id' => 'required|exists:categories,id',
            'amount' => 'required|numeric|min:0',
            'type' => 'required|in:Thu,Chi', // Bắt buộc phải có Thu/Chi
            'date' => 'required|date',
            'note' => 'nullable|string',
        ]);

        // 2. Lấy thông tin ví hiện tại
        $wallet = Wallet::where('id', $validated['wallet_id'])
                        ->where('user_id', $request->user()->id)
                        ->first();

        if (!$wallet) {
            return response()->json(['message' => 'Không tìm thấy ví'], 404);
        }

        // Bắt đầu Transaction Database để đảm bảo an toàn (Lỗi 1 cái là rollback hết)
        DB::beginTransaction();

        try {
            // 3. Tạo giao dịch mới
            // $transaction = Transaction::create($validated);
            $transactionData = $validated;
            $transactionData['user_id'] = $request->user()->id; // Lấy ID của User thật gắn vào
            $transaction = Transaction::create($transactionData);

            // 4. Cập nhật số dư của Ví (Tùy chọn: nếu app của ông đang dựa vào cột balance của Wallet)
            if ($validated['type'] === 'Thu') {
                $wallet->current_balance += $validated['amount'];
            } else {
                $wallet->current_balance -= $validated['amount'];
            }
            $wallet->save();

            // 5. CẬP NHẬT NGÂN SÁCH (Phần ông đang cần nhất đây)
            if ($validated['type'] === 'Chi') {
                // Tìm ngân sách: Trùng User, trùng Category, và ngày giao dịch NẰM TRONG chu kỳ ngân sách
                $budget = Budget::where('user_id', $request->user()->id)
                    ->where('category_id', $validated['category_id'])
                    ->whereDate('start_date', '<=', $validated['date'])
                    ->whereDate('end_date', '>=', $validated['date'])
                    ->first();

                if ($budget) {
                    $budget->spent_amount += $validated['amount'];
                    $budget->save();
                }
            }

            DB::commit(); // Xác nhận lưu tất cả

            return response()->json([
                'message' => 'Đã lưu giao dịch thành công!',
                'data' => $transaction
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack(); // Có lỗi xảy ra thì hủy bỏ toàn bộ thao tác vừa làm
            return response()->json(['message' => 'Lỗi hệ thống: ' . $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        $transaction = $this->transactionService->getTransactionById($id);
        return response()->json($transaction);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'wallet_id' => 'exists:wallets,id',
            'category_id' => 'exists:categories,id',
            'amount' => 'numeric|min:0',
            'type' => 'in:Thu,Chi',
            'date' => 'date',
        ]);
        $transaction = $this->transactionService->updateTransaction($id, $request->all(), $request->user()->id);
        return response()->json(['message' => 'Cập nhật thành công', 'data' => $transaction]);
        // $transaction = $this->transactionService->updateTransaction($id, $request->all(), 1);
        // return response()->json(['message' => 'Cập nhật thành công', 'data' => $transaction]);
    }

    public function destroy(Request $request, $id)
    {
        $this->transactionService->deleteTransaction($id, $request->user()->id);
        return response()->json(['message' => 'Xóa thành công và đã cập nhật lại ví, ngân sách']);
    }
}