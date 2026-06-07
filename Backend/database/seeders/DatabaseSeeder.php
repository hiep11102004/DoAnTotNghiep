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

        // 3. Danh mục hệ thống mặc định — user_id = null, is_default = true
        //    Hiển thị cho tất cả user, không bị xóa khi user bị xóa

        // -- CHI TIÊU (18 mục) --
        $catFood    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Ăn uống',                    'type' => 'expense', 'is_default' => true, 'icon_color' => 'orange',    'icon' => 'fastfood']);
        $catTravel  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Di chuyển',                  'type' => 'expense', 'is_default' => true, 'icon_color' => 'blue',       'icon' => 'directions_car']);
        $catShop    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Mua sắm',                    'type' => 'expense', 'is_default' => true, 'icon_color' => 'pink',       'icon' => 'shopping_bag']);
        $catEntmt   = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Giải trí',                   'type' => 'expense', 'is_default' => true, 'icon_color' => 'purple',     'icon' => 'movie']);
        $catBill    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Hóa đơn & Tiện ích',         'type' => 'expense', 'is_default' => true, 'icon_color' => 'amber',      'icon' => 'receipt_long']);
        $catHealth  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Sức khỏe & Y tế',            'type' => 'expense', 'is_default' => true, 'icon_color' => 'teal',       'icon' => 'medical_services']);
        $catEdu     = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Giáo dục',                   'type' => 'expense', 'is_default' => true, 'icon_color' => 'indigo',     'icon' => 'school']);
        $catRent    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Tiền nhà & Thuê trọ',        'type' => 'expense', 'is_default' => true, 'icon_color' => 'brown',      'icon' => 'home']);
        $catTrip    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Du lịch',                    'type' => 'expense', 'is_default' => true, 'icon_color' => 'cyan',       'icon' => 'flight']);
        $catFashion = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Quần áo & Thời trang',       'type' => 'expense', 'is_default' => true, 'icon_color' => 'red',        'icon' => 'checkroom']);
        $catBeauty  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Làm đẹp & Chăm sóc bản thân','type' => 'expense', 'is_default' => true, 'icon_color' => 'rose',       'icon' => 'spa']);
        $catHome    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Đồ gia dụng',                'type' => 'expense', 'is_default' => true, 'icon_color' => 'green',      'icon' => 'chair']);
        $catSport   = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Thể thao & Gym',             'type' => 'expense', 'is_default' => true, 'icon_color' => 'deepOrange', 'icon' => 'fitness_center']);
        $catGift    = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Quà tặng',                   'type' => 'expense', 'is_default' => true, 'icon_color' => 'pink',       'icon' => 'card_giftcard']);
        $catSaving  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Tiết kiệm & Đầu tư',        'type' => 'expense', 'is_default' => true, 'icon_color' => 'green',      'icon' => 'savings']);
        $catBankFee = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Phí ngân hàng',              'type' => 'expense', 'is_default' => true, 'icon_color' => 'grey',       'icon' => 'account_balance']);
        $catInsure  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Bảo hiểm',                  'type' => 'expense', 'is_default' => true, 'icon_color' => 'blue',       'icon' => 'security']);
        $catOtherEx = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Chi phí khác',               'type' => 'expense', 'is_default' => true, 'icon_color' => 'grey',       'icon' => 'more_horiz']);

        // -- THU NHẬP (8 mục) --
        $catSalary  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Lương',                      'type' => 'income',  'is_default' => true, 'icon_color' => 'green',      'icon' => 'payments']);
        $catBonus   = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Thưởng',                     'type' => 'income',  'is_default' => true, 'icon_color' => 'yellow',     'icon' => 'emoji_events']);
        $catFreelce = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Làm thêm & Freelance',       'type' => 'income',  'is_default' => true, 'icon_color' => 'blue',       'icon' => 'laptop']);
        $catBiz     = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Kinh doanh',                 'type' => 'income',  'is_default' => true, 'icon_color' => 'orange',     'icon' => 'store']);
        $catInvest  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Đầu tư & Lãi suất',         'type' => 'income',  'is_default' => true, 'icon_color' => 'green',      'icon' => 'trending_up']);
        $catGiftIn  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Quà & Được tặng',            'type' => 'income',  'is_default' => true, 'icon_color' => 'pink',       'icon' => 'redeem']);
        $catRefund  = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Hoàn tiền & Bồi thường',    'type' => 'income',  'is_default' => true, 'icon_color' => 'blue',       'icon' => 'replay']);
        $catOtherIn = DB::table('categories')->insertGetId(['user_id' => null, 'name' => 'Thu nhập khác',              'type' => 'income',  'is_default' => true, 'icon_color' => 'grey',       'icon' => 'more_horiz']);

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