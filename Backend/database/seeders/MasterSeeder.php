<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class MasterSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Tạo Danh mục mẫu
        \App\Models\Category::insert([
            ['name' => 'Ăn uống', 'type' => 'expense', 'icon' => 'fastfood', 'icon_color' => 'red'],
            ['name' => 'Di chuyển', 'type' => 'expense', 'icon' => 'directions_car', 'icon_color' => 'blue'],
            ['name' => 'Mua sắm', 'type' => 'expense', 'icon' => 'shopping_cart', 'icon_color' => 'orange'],
            ['name' => 'Lương', 'type' => 'income', 'icon' => 'attach_money', 'icon_color' => 'green'],
        ]);

        // 2. Tạo Huy hiệu mẫu
        \App\Models\Badge::insert([
            ['name' => 'Người tiết kiệm', 'description' => 'Đạt 100 điểm thưởng đầu tiên', 'icon_url' => 'badge_saver.png'],
            ['name' => 'Thần đèn ghi chép', 'description' => 'Ghi chép 5 giao dịch đầu tiên', 'icon_url' => 'badge_writer.png'],
        ]);

        // 3. Tạo thử thách mẫu
        \App\Models\Challenge::create([
           'name' => '7 Ngày Tiết Kiệm',
            'description' => 'Không tiêu quá 200k/ngày trong 1 tuần',
            'reward_points' => 500,
            'start_date' => now(),
            'end_date' => now()->addDays(7),
        ]);
    }
}
