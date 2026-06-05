<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'wallet_id'   => 'required|exists:wallets,id',
            'category_id' => 'required|exists:categories,id',
            'amount'      => 'required|numeric|min:0',
            'type'        => 'required|in:Thu,Chi',
            'date'        => 'required|date',
            'note'        => 'nullable|string',
        ];
    }
}
