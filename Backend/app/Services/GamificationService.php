<?php
namespace App\Services;

use App\Models\User;
use App\Models\Badge;
use App\Models\Notification;
use App\Models\Transaction;

class GamificationService
{
    // 1. Cộng điểm XP cho User
    public function addPoints($userId, $points = 10)
    {
        $user = User::find($userId);
        $user->increment('total_points', $points);

        // Sau khi cộng điểm, kiểm tra xem có đủ điều kiện nhận huy hiệu mới không
        $this->checkAndAwardBadges($user);
    }

    // 2. Kiểm tra và tặng Huy hiệu
    public function checkAndAwardBadges($user)
    {
        // Lấy danh sách huy hiệu mà User CHƯA sở hữu
        $availableBadges = Badge::whereNotIn('id', function($query) use ($user) {
            $query->select('badge_id')->from('user_badges')->where('user_id', $user->id);
        })->get();

        foreach ($availableBadges as $badge) {
            $isEligible = false;

            // Logic điều kiện cho từng loại huy hiệu
            // Ông có thể tùy biến thêm nhiều loại ở đây
            switch ($badge->name) {
                case 'Người tiết kiệm':
                    if ($user->total_points >= 100) $isEligible = true;
                    break;
                case 'Thần đèn ghi chép':
                    $count = Transaction::whereHas('wallet', fn($q) => $q->where('user_id', $user->id))->count();
                    if ($count >= 5) $isEligible = true;
                    break;
            }

            if ($isEligible) {
                // Tặng huy hiệu (Lưu vào bảng trung gian user_badges)
                $user->badges()->attach($badge->id, ['earned_at' => now()]);

                // Bắn thông báo chúc mừng
                Notification::create([
                    'user_id' => $user->id,
                    'title' => '🎉 Chúc mừng! Bạn có huy hiệu mới',
                    'message' => "Bạn vừa nhận được huy hiệu: {$badge->name}. Tiếp tục phát huy nhé!",
                    'type' => 'success'
                ]);
            }
        }
    }
}