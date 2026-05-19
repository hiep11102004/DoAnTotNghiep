<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\TransactionService;

class TransactionController extends Controller
{
    protected $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function index(Request $request)
    {
        $transactions = $this->transactionService->getAllTransactions($request->user());
        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $request->validate([
            'wallet_id' => 'required|exists:wallets,id',
            'category_id' => 'required|exists:categories,id',
            'amount' => 'required|numeric|min:0',
            'type' => 'required|in:Thu,Chi',
            'date' => 'required|date',
        ]);

        $transaction = $this->transactionService->createTransaction($request->all(), $request->user()->id);
        return response()->json(['message' => 'Thêm thành công', 'data' => $transaction], 201);
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
    }

    public function destroy(Request $request, $id)
    {
        $this->transactionService->deleteTransaction($id, $request->user()->id);
        return response()->json(['message' => 'Xóa thành công và đã cập nhật lại ví, ngân sách']);
    }
}