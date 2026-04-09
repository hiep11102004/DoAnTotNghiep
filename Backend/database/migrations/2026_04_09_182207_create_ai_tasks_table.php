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
        Schema::create('ai_tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('review_id')->constrained('ai_reviews')->cascadeOnDelete();
            $table->string('task_name');
            $table->text('description')->nullable();
            $table->integer('points_reward')->default(0);
            $table->dateTime('deadline');
            $table->string('status')->default('Chưa làm');
            $table->text('user_response')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ai_tasks');
    }
};
