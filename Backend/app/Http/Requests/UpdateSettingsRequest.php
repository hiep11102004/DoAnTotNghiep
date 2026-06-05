<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSettingsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'language'            => 'nullable|string|max:10',
            'theme'               => 'nullable|string|max:50',
            'enable_ai'           => 'nullable|boolean',
            'daily_reminder_time' => 'nullable|date_format:H:i:s',
        ];
    }
}
