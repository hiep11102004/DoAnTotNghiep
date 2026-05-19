<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // Hàm Đăng ký thành viên mới
    public function register(Request $request)
    {
        // Kiểm tra dữ liệu gửi lên từ Flutter
        $validator = Validator::make($request->all(), [
            'full_name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users', // Kiểm tra trùng username
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => $validator->errors()->first()
            ], 422);
        }

        // Tạo user mới vào bảng users
        $user = User::create([
            'full_name' => $request->full_name,
            'username' => $request->username, // Lưu username
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Tạo Token tự động đăng nhập luôn sau khi đăng ký thành công
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ], 200);
    }

    public function login(Request $request)
    {
        // Kiểm tra dữ liệu gửi lên
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        // Tìm user theo username
        $user = User::where('username', $request->username)
                    ->orWhere('email', $request->username)
                    ->first();

        // Kiểm tra user và mật khẩu
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