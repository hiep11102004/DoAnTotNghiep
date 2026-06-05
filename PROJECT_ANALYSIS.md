# PROJECT ANALYSIS

## 1. Tổng quan workspace

Workspace `DATN-FinancialAICoaching` là một hệ thống quản lý tài chính cá nhân có AI coaching, gồm 2 ứng dụng chính:

- `Backend`: Laravel 12 API server, xác thực bằng Laravel Sanctum, có tích hợp Gemini qua package `google-gemini-php/laravel`.
- `Frontend`: Flutter app, tổ chức theo hướng Clean Architecture: `core`, `feature`, `data`, `domain`, `presentation`, sử dụng `flutter_bloc` và `dio`.

Các file cấu hình trọng yếu:

- `Backend/composer.json`: Laravel 12, Sanctum, Gemini Laravel, PHPUnit, Pint.
- `Backend/package.json`: Vite, Tailwind CSS, Axios, Laravel Vite plugin.
- `Backend/routes/api.php`: toàn bộ API REST chính.
- `Backend/bootstrap/app.php`: Laravel 12 routing bootstrapping.
- `Frontend/pubspec.yaml`: Flutter SDK 3.9.2, Dio, BLoC, SharedPreferences, Device Preview, Image Picker, Gemini client, fl_chart.
- `Frontend/lib/main.dart`: khởi tạo dependency thủ công, `MultiBlocProvider`, route Flutter.
- `Frontend/lib/core/constants/app_constants.dart`: base URL và endpoint constants.

## 2. Cấu trúc thư mục tổng thể

### Backend Laravel

- `Backend/app/Http/Controllers/Api`: API controllers cho auth, ví, danh mục, giao dịch, ngân sách, mục tiêu tiết kiệm, AI, gamification, thông báo, báo cáo.
- `Backend/app/Models`: Eloquent models cho users, wallets, categories, transactions, budgets, saving goals, AI reviews/tasks, notifications, badges/challenges.
- `Backend/app/Services`: business logic tách riêng cho giao dịch và gamification.
- `Backend/database/migrations`: schema database chính.
- `Backend/database/seeders`: dữ liệu mẫu cho user, categories, wallets, transactions, budgets, AI, notifications, badges, challenges.
- `Backend/routes`: route API/web/console.
- `Backend/config`: cấu hình Laravel, cache, session, services.

Không thấy các thư mục/custom class sau trong `Backend/app`:

- `app/Http/Middleware`: không có middleware tùy biến trong repo hiện tại.
- `app/Http/Requests`: không có Form Request classes.
- `app/Http/Resources`: không thấy API Resource classes.
- `app/Events`: không thấy event classes.
- `app/Jobs`: không thấy job/queue classes.
- `app/Repositories`: không có repository layer backend.

### Frontend Flutter

- `Frontend/lib/core`: constants, network client/interceptor, error abstraction.
- `Frontend/lib/feature/auth`: đăng nhập/đăng ký.
- `Frontend/lib/feature/wallet`: ví.
- `Frontend/lib/feature/transaction`: giao dịch, dashboard, báo cáo spending.
- `Frontend/lib/feature/category`: danh mục.
- `Frontend/lib/feature/budget`: ngân sách.
- `Frontend/lib/feature/aicoaching`: AI coaching.
- `Frontend/test`: test mặc định `widget_test.dart`.

## 3. Kiến trúc tổng thể

Hệ thống đi theo mô hình client-server:

1. Flutter app hiển thị UI, quản lý state bằng BLoC.
2. Flutter dùng `DioClient` tại `Frontend/lib/core/network/dio_client.dart`.
3. `ApiInterceptor` tại `Frontend/lib/core/network/api_interceptor.dart` đọc token từ `SharedPreferences` và gắn `Authorization: Bearer <token>`.
4. Laravel nhận request qua `Backend/routes/api.php`.
5. Public routes xử lý login/register, protected routes dùng `auth:sanctum`.
6. Controllers gọi Eloquent trực tiếp hoặc service layer.
7. Database được định nghĩa qua migrations trong `Backend/database/migrations`.

Kiến trúc backend hiện tại là "Controller + Eloquent + Service một phần":

- `TransactionController` dùng `TransactionService` cho show/update/delete, nhưng store tự xử lý transaction DB, cập nhật ví và ngân sách.
- `GamificationService` xử lý cộng điểm, trao badge, tạo notification.
- Các controller khác chủ yếu truy cập model trực tiếp.
- Chưa có Repository pattern backend, Request validation classes, Resource transformers, Events/Jobs.

Kiến trúc frontend là "Clean Architecture chưa đồng nhất":

- Auth, transaction, category, AI coaching có đủ hoặc gần đủ data/domain/presentation.
- Wallet và budget có repository/datasource interface, nhưng BLoC hiện gọi Dio trực tiếp ở `wallet_bloc.dart` và `budget_bloc.dart`.
- Navigation hiện dùng route string đơn giản trong `MaterialApp`, chưa có router package.

## 4. Module/chức năng đã được xây dựng

### Authentication

Backend:

- `POST /api/register`: tạo user, hash password, tạo Sanctum token.
- `POST /api/login`: login bằng username hoặc email.
- `POST /api/logout`: xóa current access token.
- Files: `Backend/app/Http/Controllers/Api/AuthController.php`, `Backend/app/Models/User.php`, `Backend/database/migrations/2026_04_09_181401_create_users_table.php`.

Frontend:

- `LoginPage`, `RegisterPage`.
- `AuthBloc`, `AuthUsecase`, `AuthRepositoryImpl`, `AuthDatasource`, `AuthModel`.
- Token được lưu vào `SharedPreferences` tại `Frontend/lib/feature/auth/presentation/pages/login_page.dart`.

### Wallet

Backend:

- CRUD wallets qua `Route::apiResource('wallets', WalletController::class)`.
- Wallet được lọc theo user đăng nhập.
- Tạo ví với `initial_balance` đồng thời set `current_balance`.
- Files: `WalletController.php`, `Wallet.php`, migration `create_wallets_table.php`.

Frontend:

- Hiển thị ví trên dashboard và `WalletPage`.
- Tạo ví qua `AddWalletBottomSheet`.
- `WalletBloc` gọi trực tiếp `/wallets`.
- `WalletRepositoryImpl` tồn tại nhưng chưa được dùng trong `main.dart`.

### Category

Backend:

- CRUD categories qua `apiResource`.
- `index()` trả toàn bộ category, chưa lọc theo user.
- Files: `CategoryController.php`, `Category.php`, migration `create_categories_table.php`.

Frontend:

- Load categories qua `CategoryRemoteDataSourceImpl`.
- `CategoryBloc` đăng ký trong `main.dart` và fetch khi app mở.
- Dùng trong form thêm transaction.

### Transaction

Backend:

- CRUD transactions qua `apiResource('transactions')`.
- `index()` lấy transaction theo các wallet thuộc user.
- `store()` validate, tạo transaction, cập nhật `wallet.current_balance`, cập nhật `budget.spent_amount` khi type là `Chi`.
- `update()` và `destroy()` gọi `TransactionService`.
- Files: `TransactionController.php`, `TransactionService.php`, `Transaction.php`, migrations `create_transactions_table.php`, `add_type_to_transactions_table.php`.

Frontend:

- `TransactionBloc` xử lý fetch/create/update/delete.
- `TransactionDatasource` gọi `/transactions`.
- `DashboardPage` hiển thị tổng quan, tổng thu/chi, giao dịch gần đây.
- `AddTransactionBottomSheet` cho nhập giao dịch và quét hóa đơn bằng Gemini client phía Flutter.

### Budget

Backend:

- CRUD budgets qua `apiResource('budgets')`.
- Lọc ngân sách theo user.
- Tạo/cập nhật nhận cả `amount_limit` hoặc `amount`.
- Files: `BudgetController.php`, `Budget.php`, migration `create_budgets_table.php`.

Frontend:

- `BudgetBloc` gọi trực tiếp `/budgets`.
- `AddBudgetBottomSheet` tạo budget theo tháng hiện tại.
- `BudgetCard`, `BudgetPage`, dashboard budget section.

### Saving Goals

Backend:

- CRUD saving goals qua `apiResource('saving-goals')`.
- Files: `SavingGoalController.php`, `SavingGoal.php`, migration `create_saving_goals_table.php`.

Frontend:

- Có constant `AppConstants.savingGoals`.
- Chưa thấy feature Flutter riêng cho saving goals.

### AI Coaching

Backend:

- `GET /api/ai/reviews`: tổng hợp dữ liệu ví/giao dịch và gọi Gemini.
- `GET /api/ai/tasks`: trả task hard-code.
- `POST /api/ai/tasks/{id}/complete`: trả message hoàn thành task, chưa cập nhật DB.
- Files: `AIController.php`, `AI_Review.php`, `AI_Task.php`, migrations `ai_reviews`, `ai_tasks`.

Frontend:

- `AiCoachingPage` gọi `AICoachingBloc`.
- `AIDatasource` gọi `/ai/reviews`.
- Dashboard có AI card hard-code; AI tab có card động.
- `AddTransactionBottomSheet` dùng `google_generative_ai` để OCR hóa đơn, nhưng `apiKey` đang để rỗng.

### Reports

Backend:

- `GET /api/reports/spending-by-category`: group transaction theo category trong tháng hiện tại.
- Files: `ReportController.php`.

Frontend:

- `ReportBloc` gọi endpoint spending report.
- `ReportPage` render pie chart bằng `fl_chart`.

### Notifications

Backend:

- `GET /api/notifications`.
- `PUT /api/notifications/{id}/read`.
- Notifications cũng được tạo trong `TransactionService` khi vượt ngân sách và trong `GamificationService` khi nhận badge.
- Files: `NotificationController.php`, `Notification.php`, migration `notifications`.

Frontend:

- Chưa thấy feature/screen/datasource riêng cho notifications.

### Gamification

Backend:

- `GET /api/badges`.
- `GET /api/challenges`.
- `POST /api/challenges/{id}/join` được khai báo route nhưng controller chưa có method.
- `GamificationService` có logic cộng points và trao badge.
- Files: `GamificationController.php`, `GamificationService.php`, `Badge.php`, `Challenge.php`, `User_Badge.php`, `User_Challenge.php`.

Frontend:

- Dashboard và AI page có task card hard-code.
- Chưa thấy gọi API `/badges`, `/challenges`, `/ai/tasks`.

## 5. Frontend Flutter chi tiết

### Core

- `Frontend/lib/core/constants/app_constants.dart`: `baseUrl`, auth endpoints, feature endpoints, report endpoint.
- `Frontend/lib/core/network/dio_client.dart`: tạo Dio với `baseUrl`, timeout 10s, attach interceptor.
- `Frontend/lib/core/network/api_interceptor.dart`: gắn Bearer token từ `SharedPreferences`, set `Accept: application/json`.
- `Frontend/lib/core/errors/failure.dart`: abstraction lỗi cơ bản.

### Features

- `auth`: login/register.
- `wallet`: list/create wallet, screen wallet.
- `transaction`: dashboard, create/update/delete transaction, spending report.
- `category`: load category list.
- `budget`: list/create budget, budget card.
- `aicoaching`: AI review screen.

### Models

- Auth: `Frontend/lib/feature/auth/data/models/auth_model.dart`.
- Wallet: `Frontend/lib/feature/wallet/data/models/wallet_model.dart`.
- Transaction: `Frontend/lib/feature/transaction/data/models/transaction_model.dart`.
- Category spending: `Frontend/lib/feature/transaction/data/models/category_spending_model.dart`.
- Budget: `Frontend/lib/feature/budget/data/models/budget_model.dart`.
- Category: `Frontend/lib/feature/category/data/models/category_model.dart`.
- AI coaching: `Frontend/lib/feature/aicoaching/data/models/aicoaching_model.dart`.

### Repository

- `AuthRepositoryImpl`: dùng `AuthDatasource`.
- `TransactionRepositoryImpl`: dùng `TransactionDatasource`.
- `CategoryRepositoryImpl`: dùng `CategoryRemoteDataSource`.
- `AICoachingRepositoryImpl`: dùng `AICoachingDataSource`.
- `WalletRepositoryImpl`: có nhưng chưa được inject vào app; một số method chưa implement.
- `BudgetRepositoryImpl`: có nhưng cần concrete datasource thực sự; BLoC hiện gọi Dio trực tiếp.

### Data Sources

- `AuthDatasource`: `/login`, `/register`.
- `TransactionDatasource`: `/transactions`.
- `CategoryRemoteDataSourceImpl`: `/categories`.
- `AIDatasource`: `/ai/reviews`.
- `WalletDataSource`, `BudgetDataSource`, `AICoachingDataSource`: abstract interfaces.

### State Management

Toàn app dùng `flutter_bloc`:

- `AuthBloc`: login/register.
- `TransactionBloc`: fetch/create/update/delete transactions.
- `WalletBloc`: fetch/create wallets.
- `BudgetBloc`: fetch/create budgets.
- `CategoryBloc`: fetch categories.
- `ReportBloc`: fetch spending-by-category.
- `AICoachingBloc`: load AI coaching.

### Navigation

- `Frontend/lib/main.dart` dùng `MaterialApp`.
- `initialRoute: '/login'`.
- Routes hiện có:
  - `/login` -> `LoginPage`.
  - `/dashboard` -> `DashboardPage`.
- `RegisterPage` được mở bằng `MaterialPageRoute` từ `LoginPage`.
- Dashboard dùng `BottomAppBar` + `IndexedStack` cho các tab: tổng quan, báo cáo, nút add transaction, AI Coach, tài khoản.

### UI Screens

- `LoginPage`: đăng nhập, lưu token.
- `RegisterPage`: đăng ký.
- `DashboardPage`: tổng quan tài chính, ví, AI card, nhiệm vụ, budget, giao dịch gần đây.
- `ReportPage`: pie chart spending by category.
- `WalletPage`: list ví đơn giản.
- `BudgetPage`: list budget đơn giản.
- `AiCoachingPage`: review AI và task card.
- Bottom sheets:
  - `AddWalletBottomSheet`.
  - `AddBudgetBottomSheet`.
  - `AddTransactionBottomSheet`.

## 6. Backend Laravel chi tiết

### Routes

Routes tập trung ở `Backend/routes/api.php`:

- Public: login/register.
- Protected by `auth:sanctum`: user, logout, settings, wallets, categories, transactions, budgets, saving goals, AI, badges/challenges, notifications, reports.

### Controllers

- `AuthController`: register/login/logout. Route `updateSettings` đang khai báo nhưng method chưa tồn tại.
- `WalletController`: CRUD ví theo user.
- `CategoryController`: CRUD category.
- `TransactionController`: transaction CRUD, store có DB transaction.
- `BudgetController`: CRUD budget theo user.
- `SavingGoalController`: CRUD saving goals theo user.
- `AIController`: Gemini review, task hard-code, complete task hard-code.
- `GamificationController`: badges và challenges; thiếu `joinChallenge`.
- `NotificationController`: list và mark as read.
- `ReportController`: spending grouped by category.

### Services

- `TransactionService`: get transaction detail/list, create/update/delete transaction, update wallet balance, recalc budget, create budget alert notification.
- `GamificationService`: add points, award badges, create notification.

### Repositories

Backend chưa có repository classes. Controllers/services dùng Eloquent trực tiếp.

### Models

- `User`, `Wallet`, `Category`, `Transaction`, `Budget`, `SavingGoal`, `AI_Review`, `AI_Task`, `Notification`, `Badge`, `Challenge`, `User_Badge`, `User_Challenge`, `UserSetting`.

### Middleware

- Không thấy middleware tùy biến trong `app/Http/Middleware`.
- Dùng middleware framework `auth:sanctum` trong routes.

### Requests

- Không có Form Request classes.
- Validation đang nằm trực tiếp trong controller bằng `$request->validate()` hoặc `Validator::make()`.

### Resources

- Không thấy `Http/Resources`.
- API trả JSON trực tiếp từ Eloquent models/collections.

### Events và Jobs

- Không thấy event/job custom.
- `composer.json` có script dev chạy `queue:listen`, nhưng code hiện tại chưa có Jobs.

## 7. Chức năng hoàn thiện, đang phát triển, TODO, code chưa dùng, module thiếu

### Có thể xem là đã hoạt động tương đối

- Auth login/register/logout với Sanctum.
- Wallet list/create/update/delete backend; frontend list/create.
- Category list backend/frontend.
- Transaction list/create/update/delete backend/frontend.
- Budget list/create backend/frontend.
- Spending report backend/frontend.
- AI review endpoint và AI coaching screen.

### Đang phát triển hoặc chưa đồng bộ

- Account tab chỉ hiển thị "Tính năng Tài khoản đang phát triển" trong `DashboardPage`.
- Wallet update/delete trên frontend chưa implement trong `WalletRepositoryImpl`.
- AI coaching datasource chỉ implement `getCoachings`; create/update/delete/getById ném `UnimplementedError`.
- Gamification frontend đang hard-code task UI, chưa gọi badges/challenges/tasks API.
- Notifications frontend chưa có module.
- Saving goals frontend chưa có module dù backend đã có CRUD.
- Budget frontend dùng danh mục hard-code trong `AddBudgetBottomSheet`, chưa dùng `CategoryBloc`.
- Dashboard AI card vẫn hard-code, AI tab mới gọi API động.

### TODO/Debug còn tồn tại

- `Frontend/lib/feature/transaction/data/datasource/transaction_datasource.dart`: còn `print('🔥 DATA GET ĐƯỢC...')`.
- `Frontend/lib/feature/wallet/data/repository_impl/wallet_repository_impl.dart`: comment ghi tạm thời để rỗng và các method `UnimplementedError`.
- `Frontend/lib/feature/aicoaching/data/datasource/ai_datasource.dart`: các method CRUD ném `UnimplementedError`.
- `Frontend/lib/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart`: comment tạm thời và danh mục hard-code.
- `Frontend/lib/feature/transaction/presentation/widgets/add_transaction_bottom_sheet.dart`: Gemini `apiKey: ''`.

### Lệch API/schema đáng chú ý

- `Backend/routes/api.php` khai báo `PUT /user/settings`, nhưng `AuthController` không có `updateSettings`.
- `Backend/routes/api.php` khai báo `GET /transactions/summary`, nhưng `TransactionController` không có `getSummary`.
- `Backend/routes/api.php` khai báo `POST /challenges/{id}/join`, nhưng `GamificationController` không có `joinChallenge`.
- `SavingGoalController` validate/trả field `name`, `target_date`, `color`, trong khi migration/model dùng `goal_name`, `deadline`, `status`.
- `Transaction::fillable` có thể thiếu `user_id`, trong khi `TransactionController@store` gán `$transactionData['user_id']`. Migration `transactions` cũng không có `user_id`.
- `CategoryController` validate field `color`, trong khi migration/model dùng `icon_color`; Flutter `CategoryModel` cũng đọc `color`, report lại dùng `icon_color`.
- `DatabaseSeeder` tạo transactions không set `type`; migration add `type` default `Chi`, nên giao dịch thu mẫu có thể bị xem là chi nếu không được update type.
- `Budget.alert_threshold` là integer `80`, nhưng `TransactionService` dùng `$limit * $threshold`, có thể hiểu nhầm 80 thành 8000% thay vì 80%. `BudgetController` cũng default 80.

### Module còn thiếu so với domain

- Frontend profile/account/settings.
- Frontend notifications.
- Frontend saving goals.
- Frontend badges/challenges động.
- Backend user settings implementation.
- Backend API resources/DTO thống nhất response.
- Backend Form Requests cho validation.
- Backend Jobs/Events nếu muốn xử lý AI/notification async.
- Test coverage cho cả Laravel và Flutter gần như chưa có ngoài scaffold mặc định.

## 8. Package, thư viện, framework đang sử dụng

### Backend PHP/Laravel

Runtime:

- PHP `^8.2`.
- `laravel/framework ^12.0`.
- `laravel/sanctum ^4.0`.
- `google-gemini-php/laravel ^2.0`.
- `laravel/tinker ^2.10.1`.

Dev:

- `fakerphp/faker`.
- `laravel/pail`.
- `laravel/pint`.
- `laravel/sail`.
- `mockery/mockery`.
- `nunomaduro/collision`.
- `phpunit/phpunit`.

Frontend build tooling trong backend:

- `vite`.
- `laravel-vite-plugin`.
- `tailwindcss`.
- `@tailwindcss/vite`.
- `axios`.
- `concurrently`.

### Flutter

Runtime:

- `flutter`.
- `cupertino_icons`.
- `dio`.
- `shared_preferences`.
- `flutter_bloc`.
- `equatable`.
- `device_preview`.
- `image_picker`.
- `google_generative_ai`.
- `fl_chart`.

Dev:

- `flutter_test`.
- `flutter_lints`.

