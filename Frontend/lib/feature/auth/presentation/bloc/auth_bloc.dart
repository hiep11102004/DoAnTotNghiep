import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUsecase authUsecase;

  AuthBloc({required this.authUsecase}) : super(AuthInitial()) {
    
    // Xử lý sự kiện Đăng nhập
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading()); // Bắn ra trạng thái Loading để UI xoay vòng vòng
      try {
        final authEntity = await authUsecase.executeLogin(event.email, event.password);
        emit(AuthSuccess(authEntity: authEntity)); // Thành công rồi, chuyển màn hình thôi
      } catch (e) {
        emit(AuthFailure(message: e.toString().replaceAll('Exception: ', ''))); // Thất bại thì báo lỗi
      }
    });

    // Xử lý sự kiện Đăng ký
    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final authEntity = await authUsecase.executeRegister(event.name, event.email, event.password);
        emit(AuthSuccess(authEntity: authEntity));
      } catch (e) {
        emit(AuthFailure(message: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}