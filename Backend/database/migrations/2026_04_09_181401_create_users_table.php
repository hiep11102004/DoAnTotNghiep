<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id(); 
            $table->string('username')->unique();
            $table->string('password');
            $table->string('email')->unique();
            $table->string('full_name');
            $table->string('avatar')->nullable();
            $table->integer('total_points')->default(0);
            $table->string('status')->default('Hoạt động');
            $table->timestamp('join_date')->useCurrent();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
