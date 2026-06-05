<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\UpdateSettingsRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $user = User::create([
            'full_name' => $request->full_name,
            'username'  => $request->username,
            'email'     => $request->email,
            'password'  => Hash::make($request->password),
        ]);

        // Tạo Token tự động đăng nhập luôn sau khi đăng ký thành công
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status'       => 'success',
            'access_token' => $token,
            'token_type'   => 'Bearer',
            'user'         => new UserResource($user),
        ], 200);
    }

    public function login(LoginRequest $request)
    {
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
            'status'       => 'success',
            'access_token' => $token,
            'token_type'   => 'Bearer',
            'user'         => new UserResource($user),
        ]);
    }

    // Hàm Đăng xuất để hủy Token
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Đã đăng xuất thành công']);
    }

    public function getSettings(Request $request)
    {
        $settings = UserSetting::find($request->user()->id);

        return response()->json($settings ?? [
            'language'            => 'vi',
            'theme'               => 'light',
            'enable_ai'           => true,
            'daily_reminder_time' => null,
        ]);
    }

    public function updateSettings(UpdateSettingsRequest $request)
    {
        $validated = $request->validated();

        $settings = UserSetting::updateOrCreate(
            ['user_id' => $request->user()->id],
            $validated
        );

        return response()->json([
            'message' => 'Cập nhật cài đặt thành công',
            'data'    => $settings,
        ]);
    }
}