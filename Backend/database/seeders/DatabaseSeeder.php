<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Bảng Users (Ngọc Hiệp)
        $userId = DB::table('users')->insertGetId([
            'username' => 'ngochiep',
            'password' => Hash::make('password123'),
            'email' => 'hiep.it@gmail.com',
            'full_name' => 'Ngọc Hiệp',
            'avatar' => 'https://ui-avatars.com/api/?name=Ngoc+Hiep',
            'total_points' => 450,
            'status' => 'Hoạt động',
            'join_date' => Carbon::now()->subMonths(1),
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // 2. Bảng UserSettings
        DB::table('user_settings')->insert([
            'user_id' => $userId,
            'language' => 'vi',
            'theme' => 'Dark',
            'enable_ai' => true,
            'daily_reminder_time' => '21:00:00',
        ]);

        // 3. Bảng Categories (Mặc định) — type dùng 'income'/'expense' để đồng bộ với Flutter và API
        $catFood   = DB::table('categories')->insertGetId(['user_id' => $userId, 'name' => 'Ăn uống',       'type' => 'expense', 'is_default' => true, 'icon_color' => 'orange', 'icon' => 'fastfood']);
        $catRent   = DB::table('categories')->insertGetId(['user_id' => $userId, 'name' => 'Tiền trọ',      'type' => 'expense', 'is_default' => true, 'icon_color' => 'blue',   'icon' => 'home']);
        $catSalary = DB::table('categories')->insertGetId(['user_id' => $userId, 'name' => 'Lương làm thêm','type' => 'income',  'is_default' => true, 'icon_color' => 'green',  'icon' => 'attach_money']);
        $catTravel = DB::table('categories')->insertGetId(['user_id' => $userId, 'name' => 'Di chuyển',     'type' => 'expense', 'is_default' => true, 'icon_color' => 'yellow', 'icon' => 'directions_car']);

        // 4. Bảng Wallets
        $walletCash = DB::table('wallets')->insertGetId([
            'user_id' => $userId, 'name' => 'Tiền mặt', 'type' => 'Cash', 'initial_balance' => 1000000, 'current_balance' => 1000000, 'currency' => 'VND'
        ]);
        $walletBank = DB::table('wallets')->insertGetId([
            'user_id' => $userId, 'name' => 'Vietcombank', 'type' => 'Bank', 'initial_balance' => 5000000, 'current_balance' => 5000000, 'currency' => 'VND'
        ]);

        // 5. Bảng Transactions (Các giao dịch trong tuần)
        DB::table('transactions')->insert([
            ['user_id' => $userId, 'wallet_id' => $walletBank, 'category_id' => $catRent,   'type' => 'Chi', 'amount' => 2000000, 'date' => Carbon::now()->subDays(5), 'note' => 'Thanh toán tiền phòng tháng 4', 'source' => 'Manual'],
            ['user_id' => $userId, 'wallet_id' => $walletCash, 'category_id' => $catFood,   'type' => 'Chi', 'amount' => 50000,   'date' => Carbon::now()->subDays(2), 'note' => 'Ăn sáng phở bò',              'source' => 'OCR'],
            ['user_id' => $userId, 'wallet_id' => $walletBank, 'category_id' => $catSalary, 'type' => 'Thu', 'amount' => 1500000, 'date' => Carbon::now()->subDays(1), 'note' => 'Lương thực tập tháng 3',       'source' => 'Manual'],
        ]);

        // 6. Bảng Budgets
        DB::table('budgets')->insert([
            'user_id' => $userId, 'category_id' => $catFood, 'amount_limit' => 2000000, 'spent_amount' => 1250000, 'start_date' => Carbon::now()->startOfMonth(), 'end_date' => Carbon::now()->endOfMonth(), 'alert_threshold' => 80
        ]);

        // 7. Bảng SavingGoals
        DB::table('saving_goals')->insert([
            'user_id' => $userId, 'goal_name' => 'Mua Laptop Gaming', 'target_amount' => 25000000, 'current_amount' => 5000000, 'deadline' => '2026-12-31', 'status' => 'Đang thực hiện'
        ]);

        // 8. Bảng AI_Reviews
        $reviewId = DB::table('ai_reviews')->insertGetId([
            'user_id' => $userId,
            'content' => "Chào Hiệp, tuần qua bạn đã quản lý chi tiêu khá tốt. Tuy nhiên, chi phí 'Ăn uống' đang chiếm 40% tổng chi. AI dự báo nếu giữ đà này, bạn sẽ tiết kiệm thêm được 1.2tr vào cuối tháng.",
            'review_type' => 'Tuần',
            'financial_health_score' => 78,
            'forecast_data' => json_encode(['saving_prediction' => 1200000, 'status' => 'Stable']),
            'created_at' => Carbon::now()
        ]);

        // 9. Bảng AI_Tasks (Nhiệm vụ AI giao)
        DB::table('ai_tasks')->insert([
            'review_id' => $reviewId,
            'task_name' => 'Hạn chế trà sữa 3 ngày',
            'description' => 'Để tối ưu ngân sách ăn uống, hãy thử thay trà sữa bằng nước lọc trong 3 ngày tới.',
            'points_reward' => 100,
            'deadline' => Carbon::now()->addDays(3),
            'status' => 'Hoàn thành',
            'user_response' => 'Đã thực hiện xong, cảm thấy tiết kiệm được kha khá!',
            'completed_at' => Carbon::now()
        ]);

        // 10. Bảng Notifications
        DB::table('notifications')->insert([
            'user_id' => $userId, 'title' => 'Cảnh báo ngân sách', 'message' => 'Bạn đã tiêu hết 60% ngân sách ăn uống tháng này.', 'type' => 'Budget_Alert', 'is_read' => false, 'created_at' => Carbon::now()
        ]);

        // 11. Bảng Badges
        $badgeId = DB::table('badges')->insertGetId([
            'name' => 'Chiến thần tiết kiệm', 'description' => 'Hoàn thành nhiệm vụ AI trong 3 ngày liên tiếp', 'icon_url' => 'badge_saving.png', 'xp_reward' => 200
        ]);

        // 12. Bảng User_Badges
        DB::table('user_badges')->insert([
            'user_id' => $userId, 'badge_id' => $badgeId, 'earned_at' => Carbon::now()
        ]);

        // 13. Bảng Challenges
        $challengeId = DB::table('challenges')->insertGetId([
            'name' => '7 ngày nấu ăn tại nhà', 'description' => 'Không ăn ngoài trong vòng 1 tuần', 'start_date' => Carbon::now(), 'end_date' => Carbon::now()->addDays(7), 'type' => 'Hệ thống', 'reward_points' => 500
        ]);

        // 14. Bảng User_Challenges
        DB::table('user_challenges')->insert([
            'user_id' => $userId, 'challenge_id' => $challengeId, 'status' => 'Đang tham gia', 'progress' => 40
        ]);
    }
}