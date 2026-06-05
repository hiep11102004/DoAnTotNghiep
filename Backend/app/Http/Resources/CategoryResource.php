<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'         => $this->id,
            'user_id'    => $this->user_id,
            'name'       => $this->name,
            'type'       => $this->type,
            'icon'       => $this->icon,
            'color'      => $this->icon_color, // Flutter đọc 'color', DB lưu 'icon_color'
            'icon_color' => $this->icon_color,
            'is_default' => $this->is_default,
        ];
    }
}
