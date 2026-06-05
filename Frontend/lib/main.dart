import 'package:financial_app/feature/category/data/datasource/category_remote_data_source.dart';
import 'package:financial_app/feature/category/data/repository_impl/category_repository_impl.dart';
import 'package:financial_app/feature/transaction/presentation/bloc/report_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart'; 
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

// --- IMPORTS WALLET & BUDGET ---
import 'feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'feature/wallet/presentation/bloc/wallet_event.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_event.dart';

// --- IMPORTS AI COACHING ---
import 'feature/aicoaching/data/datasource/ai_datasource.dart'; 
import 'feature/aicoaching/data/repository_impl/aicoaching_repository_impl.dart';
import 'feature/aicoaching/domain/usecase/get_coachings_usecase.dart';
import 'feature/aicoaching/presentation/bloc/aicoaching_bloc.dart';

// 🚀 TẦM QUAN TRỌNG: IMPORTS CATEGORY VỪA TẠO
import 'feature/category/presentation/bloc/category_bloc.dart';

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

  // 4. KHỞI TẠO CỤM CHỨC NĂNG AI COACHING
  final aiDatasource = AIDatasource(dioClient.dio); 
  final aiRepository = AICoachingRepositoryImpl(dataSource: aiDatasource);
  final getCoachingsUseCase = GetCoachingsUseCase(aiRepository);

  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MyApp(
        dio: dioClient.dio, 
        authUsecase: authUsecase,
        getTransactionsUseCase: getTransactionsUseCase,
        createTransactionUseCase: createTransactionUseCase,
        updateTransactionUseCase: updateTransactionUseCase,
        deleteTransactionUseCase: deleteTransactionUseCase,
        getCoachingsUseCase: getCoachingsUseCase,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Dio dio; 
  final AuthUsecase authUsecase;
  
  final GetTransactionsUseCase getTransactionsUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  
  final GetCoachingsUseCase getCoachingsUseCase;
  
  const MyApp({
    super.key, 
    required this.dio, 
    required this.authUsecase,
    required this.getTransactionsUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getCoachingsUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authUsecase: authUsecase),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            getTransactionsUseCase: getTransactionsUseCase,
            createTransactionUseCase: createTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
          ),
        ),
        BlocProvider<WalletBloc>(
          create: (context) => WalletBloc(dio: dio)..add(const FetchWallets()),
        ), 
        BlocProvider<BudgetBloc>(
          create: (context) => BudgetBloc(dio: dio)..add(FetchBudgets()),
        ),
        BlocProvider<ReportBloc>(
          create: (context) => ReportBloc(dio: dio)..add(FetchCategorySpending()),
        ),
        BlocProvider<AICoachingBloc>(
          create: (context) => AICoachingBloc(this.getCoachingsUseCase),
        ),
        
        // 🚀 BÍ QUYẾT: ĐĂNG KÝ CATEGORY BLOC CHUẨN CLEAN ARCHITECTURE
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            repository: CategoryRepositoryImpl(
              remoteDataSource: CategoryRemoteDataSourceImpl(
                dio: dio,
              ),
            ),
          )..add(FetchCategories()), // Tự động load danh mục khi mở app
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