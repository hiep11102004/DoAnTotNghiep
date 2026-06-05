<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BudgetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'user_id'         => $this->user_id,
            'category_id'     => $this->category_id,
            'amount_limit'    => (float) $this->amount_limit,
            'spent_amount'    => (float) $this->spent_amount,
            'start_date'      => $this->start_date,
            'end_date'        => $this->end_date,
            'alert_threshold' => $this->alert_threshold,
            'created_at'      => $this->created_at,
            'updated_at'      => $this->updated_at,
        ];
    }
}
