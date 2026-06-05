<?php

namespace App\Providers;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // Tắt wrapper {"data": {...}} mặc định của JsonResource
        // để response format giữ nguyên như trước khi dùng Resource
        JsonResource::withoutWrapping();
    }
}
