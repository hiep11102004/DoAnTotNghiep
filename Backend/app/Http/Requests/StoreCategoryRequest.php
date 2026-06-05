<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name'       => 'required|string|max:255',
            'icon'       => 'nullable|string',
            'type'       => 'required|in:income,expense',
            'icon_color' => 'nullable|string|max:50',
        ];
    }
}
