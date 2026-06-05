<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'wallet_id'   => 'sometimes|exists:wallets,id',
            'category_id' => 'sometimes|exists:categories,id',
            'amount'      => 'sometimes|numeric|min:0',
            'type'        => 'sometimes|in:Thu,Chi',
            'date'        => 'sometimes|date',
            'note'        => 'nullable|string',
        ];
    }
}
