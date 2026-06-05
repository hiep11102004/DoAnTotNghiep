import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecase/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;

  AuthBloc({required this.authUsecase}) : super(AuthInitial()) {

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final authEntity = await authUsecase.executeLogin(event.email, event.password);
        emit(AuthSuccess(authEntity: authEntity));
      } catch (e) {
        emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final authEntity = await authUsecase.executeRegister(event.name, event.email, event.password);
        emit(AuthSuccess(authEntity: authEntity));
      } catch (e) {
        emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<LogoutSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await authUsecase.executeLogout();
      } catch (_) {
        // Dù API lỗi vẫn xóa token local và đăng xuất
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(AuthLoggedOut());
    });
  }
}