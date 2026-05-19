import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_client.dart';
import 'feature/auth/data/datasource/auth_datasource.dart';
import 'feature/auth/data/repository_impl/auth_repository_impl.dart';
import 'feature/auth/domain/usecase/auth_usecase.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/login_page.dart';
import 'feature/transaction/presentation/pages/dashboard_page.dart';

void main() {
  // Khởi tạo các lớp phụ thuộc theo đúng sơ đồ Clean Architecture
  final dioClient = DioClient();
  final authDatasource = AuthDatasource(dioClient.dio);
  final authRepository = AuthRepositoryImpl(authDatasource);
  final authUsecase = AuthUsecase(authRepository);

  runApp(MyApp(authUsecase: authUsecase));
}

class MyApp extends StatelessWidget {
  final AuthUsecase authUsecase;
  
  const MyApp({super.key, required this.authUsecase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authUsecase: authUsecase),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Financial AI Coaching',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
        },
        home: const LoginPage(),
      ),
    );
  }
}