<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Badge;
use App\Models\Challenge;
use Illuminate\Http\Request;

class GamificationController extends Controller
{
    // Xem huy hiệu của tôi
    public function getMyBadges(Request $request)
    {
        $badges = $request->user()->badges()->get();
        return response()->json($badges);
    }

    // Xem danh sách thử thách đang có
    public function index()
    {
        $challenges = Challenge::where('end_date', '>=', now())->get();
        return response()->json($challenges);
    }

    public function joinChallenge(Request $request, $id)
    {
        $challenge = Challenge::findOrFail($id);

        $alreadyJoined = $request->user()->challenges()
            ->where('challenge_id', $id)
            ->exists();

        if ($alreadyJoined) {
            return response()->json(['message' => 'Bạn đã tham gia thử thách này rồi'], 409);
        }

        $request->user()->challenges()->attach($id, [
            'status'   => 'Đang tham gia',
            'progress' => 0,
        ]);

        return response()->json(['message' => 'Tham gia thử thách thành công!', 'challenge' => $challenge]);
    }
}