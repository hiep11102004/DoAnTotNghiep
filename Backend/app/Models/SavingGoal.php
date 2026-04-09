<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SavingGoal extends Model
{
    protected $fillable = ['user_id', 'goal_name', 'target_amount', 'current_amount', 'deadline', 'status'];

    public function user() { return $this->belongsTo(User::class); }
}