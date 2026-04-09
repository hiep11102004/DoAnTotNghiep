<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // Kiểm tra dữ liệu gửi lên
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        // Tìm user theo username
        $user = User::where('username', $request->username)->first();

        // Kiểm tra user và mật khẩu (đã được mã hóa trong Seeder)
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Tên đăng nhập hoặc mật khẩu không đúng!'
            ], 401);
        }

        // Tạo Token - Đây là "vé thông hành" cho Flutter
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }

    // Hàm Đăng xuất để hủy Token
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Đã đăng xuất thành công']);
    }
}