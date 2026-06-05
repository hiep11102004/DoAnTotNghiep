<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'full_name'    => $this->full_name,
            'username'     => $this->username,
            'email'        => $this->email,
            'avatar'       => $this->avatar,
            'total_points' => $this->total_points,
            'status'       => $this->status,
            'join_date'    => $this->join_date,
            'created_at'   => $this->created_at,
        ];
    }
}
