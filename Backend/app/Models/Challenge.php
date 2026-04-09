<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Challenge extends Model
{
    protected $fillable = ['name', 'description', 'start_date', 'end_date', 'type', 'reward_points'];

    public function users() { return $this->belongsToMany(User::class, 'user_challenges'); }
}