<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateBudgetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $receivedAmount = $this->input('amount_limit') ?? $this->input('amount');
        if ($receivedAmount !== null) {
            $this->merge(['amount_limit' => $receivedAmount]);
        }
    }

    public function rules(): array
    {
        return [
            'category_id'     => 'sometimes|exists:categories,id',
            'amount_limit'    => 'sometimes|numeric|min:0',
            'start_date'      => 'sometimes|date',
            'end_date'        => 'sometimes|date|after_or_equal:start_date',
            'alert_threshold' => 'nullable|numeric',
        ];
    }
}
