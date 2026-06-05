import '../../domain/entities/auth_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<AuthEntity> login(String email, String password) async {
    final data = await datasource.login(email, password);
    return AuthModel.fromJson(data);
  }

  @override
  Future<AuthEntity> register(String name, String email, String password) async {
    final data = await datasource.register(name, email, password);
    return AuthModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await datasource.logout();
  }
}