<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Wallet;

class WalletController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // $wallets = Wallet::where('user_id', $request->user()->id)->get();
        // return response()->json($wallets);
        // 🚀 FIX TẠM: Ép cứng lấy Ví của User có ID = 1 để test UI trước.
        // (Khi nào ráp luồng Login xong thì ông mở lại code cũ: $request->user()->id)
        $wallets = \App\Models\Wallet::where('user_id', 1)->get();
        
        // Trả về thẳng mảng JSON
        return response()->json($wallets);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|string',
            'currency' => 'required|string|max:10',
            'initial_balance' => 'required|numeric|min:0',
        ]);

        $wallet = Wallet::create([
            // 'user_id' => $request->user()->id,
            'user_id' => 1,
            'name' => $validated['name'],
            'type' => $validated['type'],
            'currency' => $validated['currency'],
            'initial_balance' => $validated['initial_balance'],
            'current_balance' => $validated['initial_balance'], // Lúc mới tạo thì số dư hiện tại = số dư ban đầu
        ]);

        return response()->json($wallet, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $wallet = Wallet::where('user_id', $request->user()->id)->findOrFail($id);
        return response()->json($wallet);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $wallet = Wallet::where('user_id', $request->user()->id)->findOrFail($id);

        $validated = $request->validate([
            'name' => 'string|max:255',
            'type' => 'string',
            'currency' => 'string|max:10',
            'initial_balance' => 'numeric|min:0',
        ]);

        $wallet->update($validated);

        return response()->json($wallet);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
