import '../../domain/entities/auth_entity.dart';

abstract class AuthState {
  const AuthState();
}

// Trạng thái ban đầu (Form trống, chưa làm gì)
class AuthInitial extends AuthState {}

// Trạng thái đang đợi xử lý (Hiện vòng xoay Loading)
class AuthLoading extends AuthState {}

// Trạng thái thành công (Trả về dữ liệu AuthEntity chứa Token)
class AuthSuccess extends AuthState {
  final AuthEntity authEntity;
  const AuthSuccess({required this.authEntity});
}

// Trạng thái thất bại (Trả về chuỗi báo lỗi để hiện SnackBar)
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});
}