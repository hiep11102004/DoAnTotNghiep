<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User_Badge extends Model
{
    protected $table = 'user_badges';
    protected $fillable = ['user_id', 'badge_id', 'earned_at'];
}