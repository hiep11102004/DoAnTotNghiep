import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.id,
    required super.name,
    required super.email,
    required super.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['user']['id'] ?? 0,
      name: json['user']['full_name'] ?? '',
      email: json['user']['email'] ?? '',
      token: json['access_token'] ?? '',
    );
  }
}