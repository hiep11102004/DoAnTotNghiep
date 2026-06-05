<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateWalletRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'            => 'sometimes|string|max:255',
            'type'            => 'sometimes|string',
            'currency'        => 'sometimes|string|max:10',
            'initial_balance' => 'sometimes|numeric|min:0',
        ];
    }
}
