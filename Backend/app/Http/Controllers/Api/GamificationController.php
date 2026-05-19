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
}