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
        Schema::table('transactions', function (Blueprint $table) {
            // Viết code thêm cột type vào sau cột category_id
            $table->string('type', 10)->after('category_id')->default('Chi');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            // Lệnh để lùi lại (xóa cột) nếu ông muốn rollback
            $table->dropColumn('type');
        });
    }
};
