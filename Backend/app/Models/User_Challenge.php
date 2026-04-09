<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User_Challenge extends Model
{
    protected $table = 'user_challenges';
    protected $fillable = ['user_id', 'challenge_id', 'status', 'progress'];
}