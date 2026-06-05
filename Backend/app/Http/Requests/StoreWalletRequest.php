<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWalletRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'            => 'required|string|max:255',
            'type'            => 'required|string',
            'currency'        => 'required|string|max:10',
            'initial_balance' => 'required|numeric|min:0',
        ];
    }
}
