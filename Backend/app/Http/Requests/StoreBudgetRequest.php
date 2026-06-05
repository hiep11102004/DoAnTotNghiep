<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreBudgetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Flutter có thể gửi lên 'amount' hoặc 'amount_limit' — chuẩn hoá ở đây.
     */
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
            'category_id'     => 'required|exists:categories,id',
            'amount_limit'    => 'required|numeric|min:0',
            'start_date'      => 'required|date',
            'end_date'        => 'required|date|after_or_equal:start_date',
            'alert_threshold' => 'nullable|numeric',
        ];
    }
}
