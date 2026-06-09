import 'package:financial_app/feature/category/data/datasource/category_remote_data_source.dart';
import 'package:financial_app/feature/category/data/repository_impl/category_repository_impl.dart';
import 'package:financial_app/feature/notification/notification_bloc.dart';
import 'package:financial_app/feature/notification/notification_datasource.dart';
import 'package:financial_app/feature/notification/notification_page.dart';
import 'package:financial_app/feature/saving_goal/saving_goal_bloc.dart';
import 'package:financial_app/feature/saving_goal/saving_goal_datasource.dart';
import 'package:financial_app/feature/saving_goal/saving_goal_page.dart';
import 'package:financial_app/feature/transaction/presentation/bloc/report_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'core/network/dio_client.dart';
import 'package:device_preview/device_preview.dart';

// --- AUTH ---
import 'feature/auth/data/datasource/auth_datasource.dart';
import 'feature/auth/data/repository_impl/auth_repository_impl.dart';
import 'feature/auth/domain/usecase/auth_usecase.dart';
import 'feature/auth/presentation/bloc/auth_bloc.dart';
import 'feature/auth/presentation/pages/login_page.dart';

// --- TRANSACTION ---
import 'feature/transaction/data/datasource/transaction_datasource.dart';
import 'feature/transaction/data/repository_impl/transaction_repository_impl.dart';
import 'feature/transaction/domain/usecase/get_transactions_usecase.dart';
import 'feature/transaction/domain/usecase/create_transaction_usecase.dart';
import 'feature/transaction/domain/usecase/update_transaction_usecase.dart';
import 'feature/transaction/domain/usecase/delete_transaction_usecase.dart';
import 'feature/transaction/presentation/bloc/transaction_bloc.dart';
import 'feature/transaction/presentation/pages/dashboard_page.dart';
import 'feature/transaction/presentation/pages/transaction_list_page.dart';

// --- WALLET & BUDGET ---
import 'core/constants/app_constants.dart';
import 'feature/wallet/presentation/bloc/wallet_bloc.dart';
import 'feature/wallet/presentation/bloc/wallet_event.dart';
import 'feature/wallet/presentation/pages/wallet_page.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_bloc.dart';
import 'package:financial_app/feature/budget/presentation/bloc/budget_event.dart';

// --- AI COACHING ---
import 'feature/aicoaching/data/datasource/ai_datasource.dart';
import 'feature/aicoaching/data/repository_impl/aicoaching_repository_impl.dart';
import 'feature/aicoaching/domain/usecase/get_coachings_usecase.dart';
import 'feature/aicoaching/presentation/bloc/aicoaching_bloc.dart';

// --- CATEGORY ---
import 'feature/category/presentation/bloc/category_bloc.dart';

void main() {
  final dioClient = DioClient();

  final authDatasource = AuthDatasource(dioClient.dio);
  final authRepository = AuthRepositoryImpl(authDatasource);
  final authUsecase = AuthUsecase(authRepository);

  final transactionDatasource = TransactionDatasource(dioClient.dio);
  final transactionRepository = TransactionRepositoryImpl(transactionDatasource);
  final getTransactionsUseCase = GetTransactionsUseCase(transactionRepository);
  final createTransactionUseCase = CreateTransactionUseCase(transactionRepository);
  final updateTransactionUseCase = UpdateTransactionUseCase(transactionRepository);
  final deleteTransactionUseCase = DeleteTransactionUseCase(transactionRepository);

  final aiDatasource = AIDatasource(dioClient.dio);
  final aiRepository = AICoachingRepositoryImpl(dataSource: aiDatasource);
  final getCoachingsUseCase = GetCoachingsUseCase(aiRepository);

  final savingGoalDatasource = SavingGoalDatasource(dioClient.dio);
  final notificationDatasource = NotificationDatasource(dioClient.dio);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(
        dio: dioClient.dio,
        authUsecase: authUsecase,
        getTransactionsUseCase: getTransactionsUseCase,
        createTransactionUseCase: createTransactionUseCase,
        updateTransactionUseCase: updateTransactionUseCase,
        deleteTransactionUseCase: deleteTransactionUseCase,
        getCoachingsUseCase: getCoachingsUseCase,
        aiDatasource: aiDatasource,
        savingGoalDatasource: savingGoalDatasource,
        notificationDatasource: notificationDatasource,
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
  final AIDatasource aiDatasource;
  final SavingGoalDatasource savingGoalDatasource;
  final NotificationDatasource notificationDatasource;

  const MyApp({
    super.key,
    required this.dio,
    required this.authUsecase,
    required this.getTransactionsUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getCoachingsUseCase,
    required this.aiDatasource,
    required this.savingGoalDatasource,
    required this.notificationDatasource,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authUsecase: authUsecase),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            getTransactionsUseCase: getTransactionsUseCase,
            createTransactionUseCase: createTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
          ),
        ),
        BlocProvider<WalletBloc>(
          create: (_) => WalletBloc(dio: dio)..add(const FetchWallets()),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) => BudgetBloc(dio: dio)..add(FetchBudgets()),
        ),
        BlocProvider<ReportBloc>(
          create: (_) => ReportBloc(dio: dio)..add(FetchCategorySpending()),
        ),
        BlocProvider<AICoachingBloc>(
          create: (_) => AICoachingBloc(getCoachingsUseCase, aiDatasource),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) => CategoryBloc(
            repository: CategoryRepositoryImpl(
              remoteDataSource: CategoryRemoteDataSourceImpl(dio: dio),
            ),
          )..add(FetchCategories()),
        ),
        BlocProvider<SavingGoalBloc>(
          create: (_) => SavingGoalBloc(savingGoalDatasource),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => NotificationBloc(notificationDatasource),
        ),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: 'Financial AI Coaching',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginPage(),
          '/dashboard': (_) => const DashboardPage(),
          '/notifications': (_) => const NotificationPage(),
          '/saving-goals': (_) => const SavingGoalPage(),
          '/transactions': (_) => const TransactionListPage(),
          AppConstants.wallets: (_) => const WalletPage(),
        },
        home: const LoginPage(),
      ),
    );
  }
}
