<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWalletRequest;
use App\Http\Requests\UpdateWalletRequest;
use App\Http\Resources\WalletResource;
use Illuminate\Http\Request;
use App\Models\Wallet;

class WalletController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // 🛠️ ĐÃ MỞ KHÓA: Chỉ lấy ví của đúng user đang đăng nhập
        $wallets = Wallet::where('user_id', $request->user()->id)->get();

        return response()->json(WalletResource::collection($wallets));
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreWalletRequest $request)
    {
        $validated = $request->validated();

        $wallet = Wallet::create([
            'user_id'         => $request->user()->id,
            'name'            => $validated['name'],
            'type'            => $validated['type'],
            'currency'        => $validated['currency'],
            'initial_balance' => $validated['initial_balance'],
            'current_balance' => $validated['initial_balance'],
        ]);

        return response()->json(new WalletResource($wallet), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $wallet = Wallet::where('user_id', $request->user()->id)->findOrFail($id);
        return response()->json(new WalletResource($wallet));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateWalletRequest $request, string $id)
    {
        $wallet = Wallet::where('user_id', $request->user()->id)->findOrFail($id);
        $wallet->update($request->validated());

        return response()->json(new WalletResource($wallet));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        // Có thể bổ sung hàm xóa sau nếu cần
        $wallet = Wallet::where('user_id', $request->user()->id)->findOrFail($id);
        $wallet->delete();
        return response()->json(['message' => 'Đã xóa ví thành công']);
    }
}