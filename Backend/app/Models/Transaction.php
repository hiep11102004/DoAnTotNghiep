<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = ['user_id', 'wallet_id', 'category_id', 'type', 'amount', 'date', 'note', 'image_url', 'status', 'source'];

    public function user()     { return $this->belongsTo(User::class); }
    public function wallet()   { return $this->belongsTo(Wallet::class); }
    public function category() { return $this->belongsTo(Category::class, 'category_id'); }
}