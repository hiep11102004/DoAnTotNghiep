<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AIReview extends Model
{
    protected $table = 'ai_reviews';

    protected $fillable = [
        'user_id',
        'content',
        'review_type',
        'financial_health_score',
        'forecast_data',
    ];

    protected $casts = [
        'forecast_data' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function tasks()
    {
        return $this->hasMany(AITask::class, 'review_id');
    }
}
