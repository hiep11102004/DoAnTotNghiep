<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Http\Resources\TransactionResource;
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
        $transactions = Transaction::where('user_id', $request->user()->id)
                                   ->orderBy('date', 'desc')
                                   ->orderBy('id', 'desc')
                                   ->get();

        return response()->json(['data' => TransactionResource::collection($transactions)]);
    }

    public function store(StoreTransactionRequest $request)
    {
        $validated = $request->validated();

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
            $transactionData = $validated;
            $transactionData['user_id'] = $request->user()->id;
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
                'data'    => new TransactionResource($transaction),
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

    public function update(UpdateTransactionRequest $request, $id)
    {
        $transaction = $this->transactionService->updateTransaction($id, $request->validated(), $request->user()->id);
        return response()->json(['message' => 'Cập nhật thành công', 'data' => new TransactionResource($transaction)]);
    }

    public function destroy(Request $request, $id)
    {
        $this->transactionService->deleteTransaction($id, $request->user()->id);
        return response()->json(['message' => 'Xóa thành công và đã cập nhật lại ví, ngân sách']);
    }

    public function getSummary(Request $request)
    {
        $userId = $request->user()->id;
        $month  = (int) $request->input('month', now()->month);
        $year   = (int) $request->input('year',  now()->year);

        $base = Transaction::where('user_id', $userId)
            ->whereMonth('date', $month)
            ->whereYear('date', $year);

        $totalIncome  = (clone $base)->where('type', 'Thu')->sum('amount');
        $totalExpense = (clone $base)->where('type', 'Chi')->sum('amount');
        $totalBalance = Wallet::where('user_id', $userId)->sum('current_balance');

        return response()->json([
            'month'         => $month,
            'year'          => $year,
            'total_income'  => (float) $totalIncome,
            'total_expense' => (float) $totalExpense,
            'net'           => (float) ($totalIncome - $totalExpense),
            'total_balance' => (float) $totalBalance,
        ]);
    }
}