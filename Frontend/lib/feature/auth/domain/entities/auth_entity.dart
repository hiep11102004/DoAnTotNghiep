class AuthEntity {
  final int id;
  final String name;
  final String email;
  final String token;

  const AuthEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });
}