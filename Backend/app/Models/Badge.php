<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Badge extends Model
{
    protected $fillable = ['name', 'description', 'icon_url', 'xp_reward'];

    public function users() { return $this->belongsToMany(User::class, 'user_badges'); }
}