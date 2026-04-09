<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserSetting extends Model
{
    protected $primaryKey = 'user_id';
    public $incrementing = false;
    protected $fillable = ['user_id', 'language', 'theme', 'enable_ai', 'daily_reminder_time'];

    public function user() { return $this->belongsTo(User::class); }
}