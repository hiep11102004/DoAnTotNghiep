<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = ['wallet_id', 'category_id', 'amount', 'date', 'note', 'image_url', 'status', 'source'];

    public function wallet() { return $this->belongsTo(Wallet::class); }
    public function category() { return $this->belongsTo(Category::class); }
}