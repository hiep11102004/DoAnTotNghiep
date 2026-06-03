import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart'; // 🛠️ THÊM IMPORT DIO
import 'core/network/dio_client.dart';
import 'package:device_preview/device_preview.dart';


// --- IMPORTS AUTH ---
import 'feature/auth/data/datasource/auth_datasource.dart';
import 'feature/auth/data/repository_impl/auth_repository_impl.dart';
import 'feature/auth/domain/usecase/auth_usecase.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/login_page.dart';

// --- IMPORTS TRANSACTION ---
import 'feature/transaction/data/datasource/transaction_datasource.dart';
import 'feature/transaction/data/repository_impl/transaction_repository_impl.dart';
import 'feature/transaction/domain/usecase/get_transactions_usecase.dart';
import 'feature/transaction/domain/usecase/create_transaction_usecase.dart';
import 'feature/transaction/domain/usecase/update_transaction_usecase.dart';
import 'feature/transaction/domain/usecase/delete_transaction_usecase.dart';
import 'feature/transaction/presentation/bloc/transaction_bloc.dart';
import 'feature/transaction/presentation/pages/dashboard_page.dart';

// --- IMPORTS WALLET (MỚI THÊM) ---
// 👉 Sửa lại đường dẫn này cho khớp đúng với thư mục bloc của ông nếu cần
import 'feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'feature/wallet/presentation/bloc/wallet_event.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_event.dart';

void main() {
  // 1. Khởi tạo Dio Client dùng chung cho toàn bộ app
  final dioClient = DioClient();

  // 2. Khởi tạo cụm chức năng AUTH
  final authDatasource = AuthDatasource(dioClient.dio);
  final authRepository = AuthRepositoryImpl(authDatasource);
  final authUsecase = AuthUsecase(authRepository);

  // 3. Khởi tạo cụm chức năng TRANSACTION
  final transactionDatasource = TransactionDatasource(dioClient.dio);
  final transactionRepository = TransactionRepositoryImpl(transactionDatasource);
  
  final getTransactionsUseCase = GetTransactionsUseCase(transactionRepository);
  final createTransactionUseCase = CreateTransactionUseCase(transactionRepository);
  final updateTransactionUseCase = UpdateTransactionUseCase(transactionRepository);
  final deleteTransactionUseCase = DeleteTransactionUseCase(transactionRepository);

  runApp(
    DevicePreview(
      enabled: true, // Bật giả lập điện thoại
      builder: (context) => MyApp(
        dio: dioClient.dio, // 🛠️ BƠM DIO VÀO ĐÂY CHO WALLET BLOC DÙNG
        authUsecase: authUsecase,
        getTransactionsUseCase: getTransactionsUseCase,
        createTransactionUseCase: createTransactionUseCase,
        updateTransactionUseCase: updateTransactionUseCase,
        deleteTransactionUseCase: deleteTransactionUseCase,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Dio dio; // 🛠️ KHAI BÁO BIẾN DIO
  final AuthUsecase authUsecase;
  
  // Các UseCase của Transaction truyền qua constructor
  final GetTransactionsUseCase getTransactionsUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  
  const MyApp({
    super.key, 
    required this.dio, // 🛠️ YÊU CẦU BẮT BUỘC TRUYỀN DIO
    required this.authUsecase,
    required this.getTransactionsUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Khởi tạo AuthBloc
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authUsecase: authUsecase),
        ),
        // Khởi tạo TransactionBloc
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            getTransactionsUseCase: getTransactionsUseCase,
            createTransactionUseCase: createTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
          ),
        ),
        // 🚀 KHỞI TẠO WALLET BLOC VÀ BẮN EVENT FETCH NGAY LÚC MỞ APP
        BlocProvider<WalletBloc>(
          create: (context) => WalletBloc(dio: dio)..add(const FetchWallets()),
        ),
        BlocProvider<BudgetBloc>(
          create: (context) => BudgetBloc(dio: dio)..add(FetchBudgets()),
        ),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
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