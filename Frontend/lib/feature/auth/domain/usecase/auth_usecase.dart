import '../entities/auth_entity.dart';
import '../repository/auth_repository.dart';

class AuthUsecase {
  final AuthRepository repository;

  AuthUsecase(this.repository);

  Future<AuthEntity> executeLogin(String email, String password) async {
    return await repository.login(email, password);
  }

  Future<AuthEntity> executeRegister(String name, String email, String password) async {
    return await repository.register(name, email, password);
  }

  Future<void> executeLogout() async {
    await repository.logout();
  }
}