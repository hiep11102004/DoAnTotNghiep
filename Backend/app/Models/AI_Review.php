<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AI_Review extends Model
{
    protected $table = 'ai_reviews';
    protected $fillable = ['user_id', 'content', 'review_type', 'financial_health_score', 'forecast_data'];

    // Tự động chuyển đổi JSON thành Array khi truy xuất
    protected $casts = ['forecast_data' => 'array'];

    public function user() { return $this->belongsTo(User::class); }
    public function tasks() { return $this->hasMany(AI_Task::class, 'review_id'); }
}