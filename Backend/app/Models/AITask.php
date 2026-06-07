<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AITask extends Model
{
    protected $table = 'ai_tasks';

    protected $fillable = [
        'review_id',
        'task_name',
        'description',
        'points_reward',
        'deadline',
        'status',
        'user_response',
        'completed_at',
    ];

    protected $casts = [
        'deadline'     => 'datetime',
        'completed_at' => 'datetime',
    ];

    public function review()
    {
        return $this->belongsTo(AIReview::class, 'review_id');
    }
}
