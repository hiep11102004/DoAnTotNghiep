<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            // Thêm nullable trước để không lỗi với dữ liệu cũ
            $table->unsignedBigInteger('user_id')->nullable()->after('id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });

        // Backfill: điền user_id từ wallet tương ứng cho các bản ghi cũ
        DB::statement('
            UPDATE transactions t
            JOIN wallets w ON t.wallet_id = w.id
            SET t.user_id = w.user_id
            WHERE t.user_id IS NULL
        ');
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropColumn('user_id');
        });
    }
};
