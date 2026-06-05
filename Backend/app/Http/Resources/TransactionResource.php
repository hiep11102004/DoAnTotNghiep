<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'          => $this->id,
            'user_id'     => $this->user_id,
            'wallet_id'   => $this->wallet_id,
            'category_id' => $this->category_id,
            'amount'      => (float) $this->amount,
            'type'        => $this->type,
            'date'        => $this->date,
            'note'        => $this->note,
            'image_url'   => $this->image_url,
            'status'      => $this->status,
            'source'      => $this->source,
            'created_at'  => $this->created_at,
            'updated_at'  => $this->updated_at,
        ];
    }
}
