<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = ['username', 'password', 'email', 'full_name', 'avatar', 'total_points', 'status', 'join_date'];

    protected $hidden = ['password', 'remember_token'];

    // Quan hệ 1-1 với Cấu hình
    public function settings() { return $this->hasOne(UserSetting::class); }

    // Quan hệ 1-N
    public function wallets() { return $this->hasMany(Wallet::class); }
    public function categories() { return $this->hasMany(Category::class); }
    public function budgets() { return $this->hasMany(Budget::class); }
    public function savingGoals() { return $this->hasMany(SavingGoal::class); }
    public function aiReviews() { return $this->hasMany(AI_Review::class); }
    public function notifications() { return $this->hasMany(Notification::class); }

    // Quan hệ N-N (Gamification)
    public function badges() { return $this->belongsToMany(Badge::class, 'user_badges')->withPivot('earned_at'); }
    public function challenges() { return $this->belongsToMany(Challenge::class, 'user_challenges')->withPivot('status', 'progress'); }
}
