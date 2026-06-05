abstract class AuthEvent {
  const AuthEvent();
}

// Sự kiện khi ông ấn nút Đăng nhập
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});
}

// Sự kiện khi ông ấn nút Đăng ký
class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
}

// Sự kiện khi ông ấn nút Đăng xuất
class LogoutSubmitted extends AuthEvent {
  const LogoutSubmitted();
}