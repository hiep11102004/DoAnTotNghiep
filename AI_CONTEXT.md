# AI CONTEXT

## 1. Mục đích tài liệu

Tài liệu này là ngữ cảnh tổng hợp cho dự án `DATN-FinancialAICoaching`. Mục tiêu là giúp AI Agent hoặc lập trình viên mới hiểu toàn bộ hệ thống mà không cần đọc lại toàn bộ source code từ đầu.

Nguồn tổng hợp:

- `PROJECT_ANALYSIS.md`.
- `API_MAP.md`.
- `DATABASE_ANALYSIS.md`.
- `FEATURE_MAP.md`.

Khi bắt đầu một phiên làm việc mới, hãy đọc file này trước để nắm:

- Dự án đang làm gì.
- Frontend và Backend tổ chức như thế nào.
- API nào đang tồn tại và API nào Flutter đang gọi.
- Database có những bảng nào, quan hệ ra sao.
- Chức năng nào đã hoàn thiện, chức năng nào còn thiếu.
- Các vấn đề kỹ thuật cần đặc biệt chú ý trước khi sửa code.

## 2. Mục tiêu dự án

`DATN-FinancialAICoaching` là hệ thống quản lý tài chính cá nhân có tích hợp AI coaching. Sản phẩm hướng tới người dùng cá nhân cần:

- Theo dõi nhiều ví tiền.
- Ghi nhận giao dịch thu/chi.
- Phân loại giao dịch theo danh mục.
- Thiết lập ngân sách theo danh mục và thời gian.
- Xem báo cáo chi tiêu.
- Nhận nhận xét tài chính từ AI.
- Theo dõi nhiệm vụ, huy hiệu, thử thách gamification.
- Nhận thông báo khi vượt ngân sách hoặc đạt thành tựu.
- Theo dõi mục tiêu tiết kiệm.

Hệ thống hiện gồm hai phần chính:

- `Frontend`: ứng dụng Flutter mobile.
- `Backend`: Laravel REST API.

## 3. Kiến trúc hệ thống

### 3.1 Mô hình tổng thể

Hệ thống đi theo mô hình client-server:

```text
Flutter UI
  -> BLoC Event
  -> UseCase / Repository / DataSource hoặc BLoC gọi Dio trực tiếp
  -> DioClient + ApiInterceptor
  -> Laravel routes/api.php
  -> Controller
  -> Service nếu có
  -> Eloquent Model
  -> Database
  -> JSON response
  -> Dart Model.fromJson
  -> BLoC State
  -> UI rebuild
```

Frontend chịu trách nhiệm UI, state management và gọi API. Backend chịu trách nhiệm xác thực, xử lý nghiệp vụ, đọc/ghi database, gọi Gemini AI và trả JSON.

### 3.2 Công nghệ chính

Frontend:

- Flutter.
- Dart SDK `^3.9.2`.
- `flutter_bloc` cho state management.
- `dio` cho HTTP client.
- `shared_preferences` lưu token.
- `image_picker` chọn/chụp hóa đơn.
- `google_generative_ai` dùng OCR hóa đơn phía Flutter.
- `fl_chart` vẽ biểu đồ báo cáo.
- `device_preview` đang bật trong `main.dart`.

Backend:

- PHP `^8.2`.
- Laravel `^12.0`.
- Laravel Sanctum `^4.0` cho API token.
- `google-gemini-php/laravel` cho Gemini.
- Eloquent ORM.
- PHPUnit, Pint, Sail, Pail cho dev/test tooling.

### 3.3 Authentication architecture

- Public API gồm `/api/login` và `/api/register`.
- Protected API nằm trong middleware `auth:sanctum`.
- Sau login/register, backend tạo Sanctum token.
- Flutter lưu token vào `SharedPreferences` key `token`.
- `ApiInterceptor` đọc token và gắn `Authorization: Bearer <token>` cho các request sau.
- Backend lưu token trong bảng `personal_access_tokens`.

## 4. Cấu trúc workspace

```text
DATN-FinancialAICoaching/
├── Backend/
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Providers/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   │   ├── migrations/
│   │   ├── seeders/
│   │   └── factories/
│   ├── routes/
│   ├── tests/
│   ├── composer.json
│   └── package.json
├── Frontend/
│   ├── lib/
│   │   ├── core/
│   │   ├── feature/
│   │   └── main.dart
│   ├── test/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
├── PROJECT_ANALYSIS.md
├── API_MAP.md
├── DATABASE_ANALYSIS.md
├── FEATURE_MAP.md
└── AI_CONTEXT.md
```

## 5. Frontend Flutter

### 5.1 Cấu trúc chính

Thư mục Flutter chính: `Frontend`.

App name: `financial_app`.

Entry point:

- `Frontend/lib/main.dart`.

Core:

- `Frontend/lib/core/constants/app_constants.dart`.
- `Frontend/lib/core/network/dio_client.dart`.
- `Frontend/lib/core/network/api_interceptor.dart`.
- `Frontend/lib/core/errors/failure.dart`.

Feature folders:

- `Frontend/lib/feature/auth`.
- `Frontend/lib/feature/wallet`.
- `Frontend/lib/feature/transaction`.
- `Frontend/lib/feature/category`.
- `Frontend/lib/feature/budget`.
- `Frontend/lib/feature/aicoaching`.

### 5.2 Kiến trúc frontend

Frontend có xu hướng Clean Architecture theo feature:

```text
feature/<feature_name>/
├── data/
│   ├── datasource/
│   ├── models/
│   └── repository_impl/
├── domain/
│   ├── entities/
│   ├── repository/
│   └── usecase/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

Tuy nhiên kiến trúc chưa đồng nhất:

- Auth, Transaction, Category, AI Coaching tương đối đúng Clean Architecture.
- Wallet, Budget, Report có repository/usecase/interface nhưng BLoC hiện gọi `Dio` trực tiếp.
- Một số page tồn tại nhưng không được route tới, ví dụ `WalletPage`, `BudgetPage`.
- Một số UI đang hard-code dữ liệu hoặc chưa nối API thật.

### 5.3 Dependency injection

DI được làm thủ công trong `Frontend/lib/main.dart`.

Luồng khởi tạo:

- Tạo `DioClient`.
- Tạo Auth datasource/repository/usecase/bloc.
- Tạo Transaction datasource/repository/usecases/bloc.
- Tạo AI datasource/repository/usecase/bloc.
- Tạo Wallet/Budget/Report bloc bằng cách truyền trực tiếp `Dio`.
- Tạo Category bloc với repository và datasource inline.

Không dùng:

- `get_it`.
- `injectable`.
- `provider` cho DI.
- `go_router`.

### 5.4 Navigation

`MaterialApp` trong `main.dart` khai báo:

- `initialRoute: '/login'`.
- `routes`:
  - `/login` -> `LoginPage`.
  - `/dashboard` -> `DashboardPage`.
- `home: const LoginPage()` cũng đang được set, trùng với `initialRoute`.

Dashboard dùng `IndexedStack` và `BottomAppBar`:

- Tab 0: Tổng quan.
- Tab 1: Báo cáo.
- Tab giữa: Floating action button thêm giao dịch.
- Tab 3: AI Coach.
- Tab 4: Tài khoản, hiện chỉ là placeholder.

### 5.5 Core networking

`AppConstants.baseUrl`:

- `http://192.168.0.101:8000/api`.

`DioClient`:

- Set `baseUrl`.
- Set timeout 10 giây.
- Gắn `ApiInterceptor`.

`ApiInterceptor`:

- Đọc `SharedPreferences.getString('token')`.
- Nếu có token, gắn `Authorization: Bearer <token>`.
- Gắn `Accept: application/json`.

### 5.6 Feature frontend

#### Auth

Files chính:

- `Frontend/lib/feature/auth/presentation/pages/login_page.dart`.
- `Frontend/lib/feature/auth/presentation/pages/register_page.dart`.
- `Frontend/lib/feature/auth/presentation/bloc/auth_bloc.dart`.
- `Frontend/lib/feature/auth/data/datasource/auth_datasource.dart`.
- `Frontend/lib/feature/auth/data/repository_impl/auth_repository_impl.dart`.
- `Frontend/lib/feature/auth/domain/usecase/auth_usecase.dart`.

API:

- `POST /api/login`.
- `POST /api/register`.

Trạng thái:

- Login hoạt động cơ bản.
- Register gọi API nhưng listener trong `RegisterPage` có khả năng sai vì dùng `state == AuthSuccess` thay vì `state is AuthSuccess`.
- Chưa có auto-login khi mở app lại.
- Chưa có logout UI.

#### Transaction

Files chính:

- `Frontend/lib/feature/transaction/presentation/pages/dashboard_page.dart`.
- `Frontend/lib/feature/transaction/presentation/widgets/add_transaction_bottom_sheet.dart`.
- `Frontend/lib/feature/transaction/presentation/bloc/transaction_bloc.dart`.
- `Frontend/lib/feature/transaction/data/datasource/transaction_datasource.dart`.
- `Frontend/lib/feature/transaction/data/repository_impl/transaction_repository_impl.dart`.
- Usecases: get/create/update/delete transaction.

API:

- `GET /api/transactions`.
- `POST /api/transactions`.
- `PUT /api/transactions/{id}`.
- `DELETE /api/transactions/{id}`.

Trạng thái:

- Fetch và create có UI.
- Update/delete có BLoC/usecase/datasource nhưng chưa thấy UI thao tác rõ.
- `TransactionDatasource` còn debug `print`.
- Add transaction có OCR hóa đơn bằng Gemini phía Flutter nhưng `apiKey` đang để rỗng.

#### Wallet

Files chính:

- `Frontend/lib/feature/wallet/presentation/bloc/wallet_bloc.dart`.
- `Frontend/lib/feature/wallet/presentation/widgets/add_wallet_bottom_sheet.dart`.
- `Frontend/lib/feature/wallet/presentation/pages/wallet_page.dart`.
- `Frontend/lib/feature/wallet/data/repository_impl/wallet_repository_impl.dart`.

API:

- `GET /api/wallets`.
- `POST /api/wallets`.

Trạng thái:

- Dashboard fetch và tạo ví được.
- `WalletBloc` gọi Dio trực tiếp.
- `WalletRepositoryImpl` tồn tại nhưng chưa wire vào app.
- `getWalletById`, `updateWallet`, `deleteWallet` đang `UnimplementedError`.
- `WalletPage` không được navigate tới.

#### Budget

Files chính:

- `Frontend/lib/feature/budget/presentation/bloc/budget_bloc.dart`.
- `Frontend/lib/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart`.
- `Frontend/lib/feature/budget/presentation/widgets/budget_card.dart`.
- `Frontend/lib/feature/budget/presentation/pages/budget_page.dart`.

API:

- `GET /api/budgets`.
- `POST /api/budgets`.

Trạng thái:

- Dashboard fetch và tạo budget được.
- `BudgetBloc` gọi Dio trực tiếp.
- `BudgetRepositoryImpl` và `BudgetDataSource` chưa được dùng đúng trong app.
- `AddBudgetBottomSheet` dùng category hard-code id 1-6.
- `BudgetPage` không được route tới.
- `AddBudget` event đang được định nghĩa trong `budget_bloc.dart`, không nằm trong `budget_event.dart`.

#### Category

Files chính:

- `Frontend/lib/feature/category/presentation/bloc/category_bloc.dart`.
- `Frontend/lib/feature/category/data/datasource/category_remote_data_source.dart`.
- `Frontend/lib/feature/category/data/repository_impl/category_repository_impl.dart`.
- `Frontend/lib/feature/category/data/models/category_model.dart`.

API:

- `GET /api/categories`.

Trạng thái:

- Load danh mục từ API.
- Được dùng trong form thêm transaction.
- Chưa dùng trong add budget.
- `CategoryModel` đọc field `color`, trong khi backend/database dùng `icon_color`.

#### Report

Files chính:

- `Frontend/lib/feature/transaction/presentation/pages/report_page.dart`.
- `Frontend/lib/feature/transaction/presentation/bloc/report_bloc.dart`.
- `Frontend/lib/feature/transaction/data/models/category_spending_model.dart`.

API:

- `GET /api/reports/spending-by-category`.

Trạng thái:

- Có pie chart bằng `fl_chart`.
- Report BLoC gọi Dio trực tiếp.
- Backend hiện chưa lọc rõ `type = Chi`, nên báo cáo có thể cộng cả thu và chi.

#### AI Coaching

Files chính:

- `Frontend/lib/feature/aicoaching/presentation/pages/aicoaching_page.dart`.
- `Frontend/lib/feature/aicoaching/presentation/bloc/aicoaching_bloc.dart`.
- `Frontend/lib/feature/aicoaching/data/datasource/ai_datasource.dart`.
- `Frontend/lib/feature/aicoaching/data/repository_impl/aicoaching_repository_impl.dart`.

API:

- `GET /api/ai/reviews`.

Trạng thái:

- AI tab gọi API thật.
- Dashboard AI card vẫn hard-code.
- `AIDatasource` chỉ implement `getCoachings`.
- `getById`, create, update, delete ném `UnimplementedError`.
- Constants `aiReviews = '/ai-reviews'`, `aiTasks = '/ai-tasks'` không khớp route Laravel thực tế `/ai/reviews`, `/ai/tasks`.

## 6. Backend Laravel

### 6.1 Cấu trúc backend

Thư mục Laravel chính: `Backend`.

Files/thư mục quan trọng:

- `Backend/routes/api.php`: định nghĩa API.
- `Backend/bootstrap/app.php`: Laravel 12 routing bootstrap.
- `Backend/app/Http/Controllers/Api`: API controllers.
- `Backend/app/Models`: Eloquent models.
- `Backend/app/Services`: service layer một phần.
- `Backend/database/migrations`: schema.
- `Backend/database/seeders`: dữ liệu mẫu.
- `Backend/composer.json`: package PHP.
- `Backend/config/gemini.php`: cấu hình Gemini.

### 6.2 Kiến trúc backend hiện tại

Backend là API monolith mỏng:

```text
routes/api.php
  -> Api Controller
  -> Service nếu có
  -> Eloquent Model
  -> Database
```

Có:

- Controllers.
- Models.
- Services: `TransactionService`, `GamificationService`.
- Sanctum auth.
- Gemini integration.

Chưa có:

- Repository layer.
- Form Request classes.
- API Resource classes.
- Custom Middleware.
- Events/Listeners.
- Jobs/Queues tùy chỉnh.
- Policies.

Validation đang nằm trực tiếp trong controller. Response thường trả JSON trực tiếp từ Eloquent model/collection hoặc array.

### 6.3 Controllers

Controllers chính:

- `AuthController`: login/register/logout.
- `WalletController`: CRUD ví.
- `CategoryController`: CRUD danh mục.
- `TransactionController`: CRUD giao dịch.
- `BudgetController`: CRUD ngân sách.
- `SavingGoalController`: CRUD mục tiêu tiết kiệm.
- `AIController`: Gemini review, AI tasks stub.
- `GamificationController`: badges/challenges.
- `NotificationController`: notifications.
- `ReportController`: báo cáo chi tiêu.

### 6.4 Services

`TransactionService`:

- Lấy list/detail transaction.
- Tạo/update/delete transaction.
- Cập nhật wallet balance.
- Tính lại budget.
- Tạo notification vượt budget.
- Có logic gọi `GamificationService` khi tạo transaction, nhưng method `createTransaction()` hiện không được controller store sử dụng.

`GamificationService`:

- Cộng điểm user.
- Check và trao badge.
- Tạo notification khi nhận badge.

### 6.5 Models

Models chính:

- `User`.
- `UserSetting`.
- `Wallet`.
- `Category`.
- `Transaction`.
- `Budget`.
- `SavingGoal`.
- `AI_Review`.
- `AI_Task`.
- `Notification`.
- `Badge`.
- `Challenge`.
- `User_Badge`.
- `User_Challenge`.

## 7. Database Schema

### 7.1 Danh sách bảng

Database có các bảng:

- `users`.
- `personal_access_tokens`.
- `user_settings`.
- `wallets`.
- `categories`.
- `transactions`.
- `budgets`.
- `saving_goals`.
- `ai_reviews`.
- `ai_tasks`.
- `notifications`.
- `badges`.
- `user_badges`.
- `challenges`.
- `user_challenges`.

### 7.2 Quan hệ chính

```text
users
  |-- user_settings (1-1)
  |-- wallets (1-n)
  |     |-- transactions (1-n)
  |             |-- categories (n-1)
  |-- categories (1-n, optional/global when user_id null)
  |-- budgets (1-n)
  |     |-- categories (n-1)
  |-- saving_goals (1-n)
  |-- ai_reviews (1-n)
  |     |-- ai_tasks (1-n)
  |-- notifications (1-n)
  |-- badges (n-n through user_badges)
  |-- challenges (n-n through user_challenges)
  |-- personal_access_tokens (1-n via Sanctum tokenable)
```

### 7.3 Bảng `users`

Columns:

- `id`.
- `username` unique.
- `password`.
- `email` unique.
- `full_name`.
- `avatar` nullable.
- `total_points` default `0`.
- `status` default `Hoạt động`.
- `join_date`.
- `remember_token`.
- timestamps.

Quan hệ:

- hasOne `UserSetting`.
- hasMany wallets, categories, budgets, saving goals, AI reviews, notifications.
- belongsToMany badges/challenges.

### 7.4 Bảng `wallets`

Columns:

- `id`.
- `user_id`.
- `name`.
- `type`.
- `initial_balance`.
- `current_balance`.
- `currency`.
- `note`.
- timestamps.

Vai trò:

- Mỗi ví thuộc một user.
- Giao dịch thuộc về ví.
- Balance được cập nhật khi tạo/update/delete giao dịch.

### 7.5 Bảng `categories`

Columns:

- `id`.
- `user_id` nullable.
- `name`.
- `type`.
- `icon_color`.
- `is_default`.
- `icon`.
- timestamps.

Vai trò:

- Phân loại giao dịch và ngân sách.
- Có thể là category mặc định nếu `user_id` null.

Lưu ý:

- Backend controller dùng field `color`, database dùng `icon_color`.
- Type category chưa thống nhất: `income/expense`, `Thu nhập/Chi phí`, trong khi transaction dùng `Thu/Chi`.

### 7.6 Bảng `transactions`

Columns:

- `id`.
- `wallet_id`.
- `category_id`.
- `type` default `Chi`.
- `amount`.
- `date`.
- `note`.
- `image_url`.
- `status`.
- `source`.
- timestamps.

Vai trò:

- Bảng trung tâm cho dashboard, report, AI review, budget tracking.
- User ownership được suy ra qua `wallet_id -> wallets.user_id`.

Lưu ý:

- Controller store có gán `user_id`, nhưng bảng và model transaction không có `user_id`.

### 7.7 Bảng `budgets`

Columns:

- `id`.
- `user_id`.
- `category_id`.
- `amount_limit`.
- `spent_amount`.
- `start_date`.
- `end_date`.
- `alert_threshold` default `80`.
- timestamps.

Vai trò:

- Theo dõi hạn mức chi theo category và thời gian.
- Khi transaction `Chi` được tạo, backend cập nhật `spent_amount`.

Lưu ý:

- `alert_threshold` lưu 80 như phần trăm nhưng service đang dùng như tỷ lệ trực tiếp.

### 7.8 Bảng `saving_goals`

Columns:

- `id`.
- `user_id`.
- `goal_name`.
- `target_amount`.
- `current_amount`.
- `deadline`.
- `status`.
- timestamps.

Lưu ý:

- Controller đang dùng `name`, `target_date`, `color`.
- Schema/model dùng `goal_name`, `deadline`, không có `color`.

### 7.9 Bảng AI

`ai_reviews`:

- `user_id`.
- `content`.
- `review_type`.
- `financial_health_score`.
- `forecast_data`.

`ai_tasks`:

- `review_id`.
- `task_name`.
- `description`.
- `points_reward`.
- `deadline`.
- `status`.
- `user_response`.
- `completed_at`.

Lưu ý:

- Schema và seeder có AI reviews/tasks.
- API hiện tại không đọc/ghi các bảng này cho AI runtime.
- `AIController@getReviews` gọi Gemini realtime.
- `AIController@getTasks` trả hard-code.

### 7.10 Bảng notification và gamification

`notifications`:

- `user_id`.
- `title`.
- `message`.
- `type`.
- `is_read`.

`badges`:

- `name`.
- `description`.
- `icon_url`.
- `xp_reward`.

`user_badges`:

- `user_id`.
- `badge_id`.
- `earned_at`.

`challenges`:

- `name`.
- `description`.
- `start_date`.
- `end_date`.
- `type`.
- `reward_points`.

`user_challenges`:

- `user_id`.
- `challenge_id`.
- `status`.
- `progress`.

## 8. API Mapping

### 8.1 Base URL

Frontend base URL:

- `http://192.168.0.101:8000/api`.

File:

- `Frontend/lib/core/constants/app_constants.dart`.

### 8.2 Public API

- `POST /api/login`.
- `POST /api/register`.

### 8.3 Protected API

Tất cả endpoint sau dùng `auth:sanctum`:

Auth/User:

- `GET /api/user`.
- `POST /api/logout`.
- `PUT /api/user/settings`.

Wallet:

- `GET /api/wallets`.
- `POST /api/wallets`.
- `GET /api/wallets/{id}`.
- `PUT/PATCH /api/wallets/{id}`.
- `DELETE /api/wallets/{id}`.

Category:

- `GET /api/categories`.
- `POST /api/categories`.
- `GET /api/categories/{id}`.
- `PUT/PATCH /api/categories/{id}`.
- `DELETE /api/categories/{id}`.

Transaction:

- `GET /api/transactions/summary`.
- `GET /api/transactions`.
- `POST /api/transactions`.
- `GET /api/transactions/{id}`.
- `PUT/PATCH /api/transactions/{id}`.
- `DELETE /api/transactions/{id}`.

Budget:

- `GET /api/budgets`.
- `POST /api/budgets`.
- `GET /api/budgets/{id}`.
- `PUT/PATCH /api/budgets/{id}`.
- `DELETE /api/budgets/{id}`.

Saving Goal:

- `GET /api/saving-goals`.
- `POST /api/saving-goals`.
- `GET /api/saving-goals/{id}`.
- `PUT/PATCH /api/saving-goals/{id}`.
- `DELETE /api/saving-goals/{id}`.

AI:

- `GET /api/ai/reviews`.
- `GET /api/ai/tasks`.
- `POST /api/ai/tasks/{id}/complete`.

Gamification:

- `GET /api/badges`.
- `GET /api/challenges`.
- `POST /api/challenges/{id}/join`.

Notification:

- `GET /api/notifications`.
- `PUT /api/notifications/{id}/read`.

Report:

- `GET /api/reports/spending-by-category`.

### 8.4 API Flutter đang gọi thực tế

Flutter hiện gọi:

- `POST /api/login`.
- `POST /api/register`.
- `GET /api/wallets`.
- `POST /api/wallets`.
- `GET /api/categories`.
- `GET /api/transactions`.
- `POST /api/transactions`.
- `PUT /api/transactions/{id}`.
- `DELETE /api/transactions/{id}`.
- `GET /api/budgets`.
- `POST /api/budgets`.
- `GET /api/ai/reviews`.
- `GET /api/reports/spending-by-category`.

Backend có nhưng Flutter chưa tích hợp:

- Logout.
- User profile/settings.
- Saving goals.
- Notifications.
- Badges/challenges.
- AI tasks.
- Full category CRUD.
- Wallet update/delete.
- Budget update/delete.
- Transaction summary.

### 8.5 API khai báo nhưng có vấn đề

Các route trỏ tới method chưa tồn tại:

- `PUT /api/user/settings` -> `AuthController@updateSettings`.
- `GET /api/transactions/summary` -> `TransactionController@getSummary`.
- `POST /api/challenges/{id}/join` -> `GamificationController@joinChallenge`.

Constants không khớp route:

- `AppConstants.aiReviews = '/ai-reviews'`, route thật là `/ai/reviews`.
- `AppConstants.aiTasks = '/ai-tasks'`, route thật là `/ai/tasks`.

## 9. Luồng nghiệp vụ chính

### 9.1 Đăng ký

1. User nhập họ tên, email, password trên `RegisterPage`.
2. Flutter gửi `POST /api/register`.
3. Backend validate:
   - `full_name`.
   - `username`.
   - `email`.
   - `password`.
4. Backend tạo user, hash password.
5. Backend tạo Sanctum token.
6. Flutter nhận token và user.

Lưu ý:

- Register hiện tự trả token, nhưng UI register có thể chưa xử lý success đúng do check state sai.
- Backend chưa tự tạo `user_settings` khi register.

### 9.2 Đăng nhập

1. User nhập email/password trên `LoginPage`.
2. Flutter dispatch `LoginSubmitted`.
3. `AuthBloc` gọi `AuthUsecase`.
4. `AuthDatasource` gọi `POST /api/login`.
5. Backend tìm user theo username hoặc email.
6. Backend kiểm tra password.
7. Backend tạo Sanctum token.
8. Flutter lưu token vào `SharedPreferences`.
9. Flutter chuyển sang `/dashboard`.

### 9.3 Load dashboard

Khi vào `DashboardPage`:

1. Dispatch `FetchTransactions`.
2. Dispatch `FetchWallets`.
3. `main.dart` đã tạo sẵn `BudgetBloc` và `ReportBloc` với initial fetch.
4. Dashboard render:
   - Tổng thu.
   - Tổng chi.
   - Tổng số dư.
   - Danh sách ví.
   - Budget section.
   - Giao dịch gần đây.
   - AI card mock.
   - Task card mock.

### 9.4 Tạo ví

1. User mở `AddWalletBottomSheet`.
2. Nhập tên ví và số dư ban đầu.
3. Flutter dispatch `CreateWallet`.
4. `WalletBloc` gọi `POST /api/wallets`.
5. Backend validate `name`, `type`, `currency`, `initial_balance`.
6. Backend tạo ví với `current_balance = initial_balance`.
7. Flutter fetch lại wallets.

### 9.5 Tạo giao dịch

1. User mở `AddTransactionBottomSheet`.
2. Chọn loại `Thu` hoặc `Chi`.
3. Chọn ví và danh mục.
4. Nhập số tiền, ghi chú, ngày.
5. Có thể chọn/chụp ảnh hóa đơn để Gemini client parse amount/note.
6. Flutter dispatch `AddTransactionSubmitted`.
7. `TransactionBloc` gọi usecase/repository/datasource.
8. Dio gửi `POST /api/transactions`.
9. Backend validate:
   - `wallet_id`.
   - `category_id`.
   - `amount`.
   - `type` in `Thu,Chi`.
   - `date`.
   - `note`.
10. Backend đảm bảo wallet thuộc user hiện tại.
11. Backend tạo transaction.
12. Backend cập nhật wallet balance:
   - `Thu`: cộng tiền.
   - `Chi`: trừ tiền.
13. Nếu là `Chi`, backend tìm budget cùng user/category và date nằm trong kỳ ngân sách để tăng `spent_amount`.
14. Flutter refresh transactions, wallets, budgets/report.

### 9.6 Cập nhật/xóa giao dịch

Backend đã có logic:

- Update: hoàn tác balance cũ, update transaction, áp dụng balance mới.
- Delete: hoàn tác balance, xóa transaction, tính lại budget.

Frontend đã có BLoC/usecase/datasource nhưng UI thao tác sửa/xóa chưa thấy đầy đủ.

### 9.7 Tạo ngân sách

1. User mở `AddBudgetBottomSheet`.
2. Chọn category từ danh sách hard-code.
3. Nhập hạn mức.
4. UI tự tính `start_date` là ngày đầu tháng và `end_date` là ngày cuối tháng.
5. Flutter dispatch `AddBudget`.
6. `BudgetBloc` gọi `POST /api/budgets`.
7. Backend tạo budget với `spent_amount = 0`, `alert_threshold = 80`.

### 9.8 Báo cáo chi tiêu

1. `ReportBloc` gọi `GET /api/reports/spending-by-category`.
2. Backend lọc transactions thuộc wallets của user trong tháng/năm hiện tại.
3. Backend group theo `category_id`, sum `amount`.
4. Backend eager-load category `id,name,icon_color`.
5. Flutter parse `CategorySpendingModel`.
6. `ReportPage` vẽ pie chart.

Lưu ý:

- Backend đang comment filter `type = Chi`, nên report có thể cộng cả thu nhập.

### 9.9 AI Coaching

1. User mở tab AI Coach.
2. `AiCoachingPage` dispatch `LoadAICoachingEvent`.
3. Flutter gọi `GET /api/ai/reviews`.
4. Backend lấy:
   - Tổng số dư ví.
   - Tổng thu tháng hiện tại.
   - Tổng chi tháng hiện tại.
   - Các ghi chú chi gần đây.
5. Backend tạo prompt tiếng Việt.
6. Backend gọi Gemini.
7. Backend parse JSON response và trả `{ review: ... }`.
8. Flutter hiển thị nhận xét.

Lưu ý:

- API không lưu review vào `ai_reviews`.
- Nếu Gemini lỗi, backend trả HTTP 200 với nội dung lỗi trong review.
- Dashboard AI card vẫn là text hard-code, không dùng API.

### 9.10 Notifications và gamification

Backend đã có schema và service:

- Notification khi vượt ngân sách.
- Notification khi nhận badge.
- Badge khi đủ điểm hoặc đủ số lượng giao dịch.
- Challenges active.

Nhưng:

- Flutter chưa có màn hình notification.
- Flutter chưa gọi badges/challenges API.
- Route join challenge thiếu method.
- Tạo transaction hiện đi qua `TransactionController@store` inline, không gọi `TransactionService@createTransaction`, nên logic add points có thể không chạy.

## 10. Quy tắc nghiệp vụ quan trọng

### 10.1 Giao dịch thuộc user thông qua ví

`transactions` không có `user_id`. Giao dịch thuộc user qua:

```text
transactions.wallet_id -> wallets.id -> wallets.user_id
```

Khi query transaction theo user, nên lọc qua wallets của user.

### 10.2 Cập nhật số dư ví

Khi tạo transaction:

- `type = Thu`: `wallet.current_balance += amount`.
- `type = Chi`: `wallet.current_balance -= amount`.

Khi update transaction:

- Hoàn tác transaction cũ khỏi ví.
- Update dữ liệu transaction.
- Áp dụng transaction mới vào ví.

Khi delete transaction:

- Hoàn tác transaction khỏi ví.
- Xóa transaction.

### 10.3 Cập nhật ngân sách

Khi tạo giao dịch `Chi`:

- Tìm budget cùng `user_id`, `category_id`.
- Kiểm tra ngày giao dịch nằm giữa `start_date` và `end_date`.
- Tăng `spent_amount`.

Trong `TransactionService`, có logic tính lại total spent theo tháng và cập nhật `spent_amount`.

### 10.4 Cảnh báo ngân sách

Ý định nghiệp vụ:

- Nếu tổng chi đạt ngưỡng cảnh báo, tạo notification.
- Tránh spam bằng cách kiểm tra notification trong ngày.

Vấn đề:

- `alert_threshold` lưu `80`, nhưng service tính `$limit * $threshold`.
- Nên hiểu là phần trăm và tính `$limit * ($threshold / 100)`.

### 10.5 Category type chưa thống nhất

Hiện có nhiều hệ giá trị:

- Category controller validate `income`, `expense`.
- Seeder dùng `Chi phí`, `Thu nhập`.
- Transaction dùng `Thu`, `Chi`.
- UI có logic lọc category theo thu/chi.

Khi sửa category, cần chuẩn hóa enum hoặc mapping.

### 10.6 AI review không persist

Hiện AI review realtime:

- Đọc wallets/transactions.
- Gọi Gemini.
- Trả response.
- Không ghi `ai_reviews`.

Nếu cần lịch sử AI review, phải bổ sung persistence.

### 10.7 Tasks/gamification chưa nối dữ liệu thật

- AI tasks backend hard-code.
- Task cards frontend hard-code.
- Badge/challenge có schema/API nhưng chưa có frontend.

## 11. Chức năng đã hoàn thành tương đối

Các chức năng có thể xem là đã hoạt động ở mức cơ bản:

- Đăng ký user.
- Đăng nhập user.
- Lưu token và tự gắn Bearer token.
- Load dashboard.
- List ví.
- Tạo ví.
- Load danh mục.
- List giao dịch.
- Tạo giao dịch.
- Update/delete giao dịch ở tầng API/BLoC.
- List ngân sách.
- Tạo ngân sách.
- Báo cáo chi tiêu theo danh mục.
- AI coaching review từ Gemini.
- Backend notifications list/mark read.
- Backend badges/challenges list.
- Backend saving goals CRUD route/controller, nhưng còn mismatch field.

## 12. Chức năng còn thiếu hoặc đang phát triển

Frontend thiếu:

- Logout UI.
- Auto-login/session restore.
- Profile/account/settings screen.
- User settings UI.
- Notifications screen.
- Saving goals feature.
- Badges/challenges feature.
- AI tasks dynamic UI.
- Wallet update/delete UI.
- Budget update/delete UI.
- Category CRUD UI.
- Transaction edit/delete UI hoàn chỉnh.
- Report filter theo thời gian.
- Route guard theo auth state.
- Localization/i18n.
- Unit/widget tests thực tế.

Backend thiếu:

- `AuthController@updateSettings`.
- `TransactionController@getSummary`.
- `GamificationController@joinChallenge`.
- Đồng bộ saving goals controller với schema.
- Đồng bộ category `color/icon_color` và `type`.
- API persist AI reviews/tasks.
- Logic complete AI task thật.
- Logic join challenge thật.
- Form Request classes.
- API Resource classes.
- Policies/authorization rõ ràng.
- Jobs/Events cho AI/notification nếu cần async.
- Tests API.

## 13. Vấn đề kỹ thuật cần lưu ý

### 13.1 Route broken

Ba endpoint sẽ lỗi nếu gọi vì route trỏ tới method chưa tồn tại:

- `PUT /api/user/settings`.
- `GET /api/transactions/summary`.
- `POST /api/challenges/{id}/join`.

### 13.2 Schema mismatch

Saving goals:

- Controller dùng `name`, `target_date`, `color`.
- DB/model dùng `goal_name`, `deadline`, `status`, không có `color`.

Category:

- Controller dùng `color`.
- DB/model dùng `icon_color`.
- Flutter category model đọc `color`.
- Report đọc `icon_color`.

Transaction:

- Controller gán `user_id`.
- DB/model không có `user_id`.

Budget:

- `alert_threshold` đang có mismatch giữa phần trăm và tỷ lệ.

### 13.3 Authorization chưa đồng nhất

Cần cẩn thận với:

- `CategoryController` CRUD global, chưa scope theo user.
- `TransactionController@show` gọi service tìm transaction theo id, chưa verify ownership.
- Transaction update/delete service cần kiểm tra chắc chắn transaction thuộc user.

### 13.4 Kiến trúc frontend chưa đồng nhất

- Wallet/Budget/Report gọi Dio trực tiếp trong BLoC.
- Auth/Transaction/Category/AI có repository/usecase.
- Một số repository/usecase không được dùng.

Khi refactor, nên chọn một hướng nhất quán:

- Hoặc chuẩn hóa tất cả qua Clean Architecture.
- Hoặc chấp nhận BLoC gọi repository mỏng, nhưng loại bỏ dead code.

### 13.5 Dead code và placeholder

Dead/orphan code đáng chú ý:

- `Frontend/lib/core/errors/failure.dart`.
- `WalletRepositoryImpl` chưa wire, có `UnimplementedError`.
- `BudgetRepositoryImpl` chưa wire.
- `WalletPage`, `BudgetPage` không được route tới.
- AI datasource CRUD methods `UnimplementedError`.
- Dashboard AI card hard-code.
- Dashboard task card hard-code.
- Account tab placeholder.
- `DatabaseSeeder` và `MasterSeeder` có dữ liệu seed không đồng nhất.

### 13.6 Debug/dev artifact

- `DevicePreview(enabled: true)` trong `main.dart`.
- `TransactionDatasource` còn `print`.
- `AddTransactionBottomSheet` có Gemini `apiKey: ''`.
- Test Flutter mặc định có thể lỗi vì `MyApp` cần params.

### 13.7 Report có thể sai nghiệp vụ

`ReportController@getSpendingByCategory` đang không filter `type = Chi`, nên báo cáo chi tiêu có thể cộng cả giao dịch thu.

### 13.8 AI key/config

Backend dùng Gemini Laravel config. Cần đảm bảo `.env` có `GEMINI_API_KEY`, trong khi `.env.example` có thể chưa khai báo rõ.

Frontend OCR Gemini đang dùng `apiKey: ''`, không thể chạy thực tế nếu không cấu hình.

## 14. Package và thư viện

### 14.1 Flutter packages

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

### 14.2 Backend PHP packages

Runtime:

- `laravel/framework`.
- `laravel/sanctum`.
- `google-gemini-php/laravel`.
- `laravel/tinker`.

Dev:

- `fakerphp/faker`.
- `laravel/pail`.
- `laravel/pint`.
- `laravel/sail`.
- `mockery/mockery`.
- `nunomaduro/collision`.
- `phpunit/phpunit`.

Backend npm/dev assets:

- `vite`.
- `laravel-vite-plugin`.
- `tailwindcss`.
- `@tailwindcss/vite`.
- `axios`.
- `concurrently`.

## 15. Quy ước khi làm việc tiếp

### 15.1 Khi sửa frontend

Nên kiểm tra:

- Feature đó đang đi qua Clean Architecture hay BLoC gọi Dio trực tiếp.
- BLoC đã được đăng ký trong `main.dart` chưa.
- API path dùng constant hay hard-code.
- Token có cần không.
- Model JSON có khớp backend không.
- Page có được route tới không.

Nếu thêm feature mới, nên ưu tiên cấu trúc:

```text
feature/<name>/
├── data/
│   ├── datasource/
│   ├── models/
│   └── repository_impl/
├── domain/
│   ├── entities/
│   ├── repository/
│   └── usecase/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

### 15.2 Khi sửa backend

Nên kiểm tra:

- Route đã có trong `routes/api.php` chưa.
- Controller method có tồn tại không.
- Validation có khớp migration/model không.
- Query có scope theo user không.
- Response có khớp Dart model không.
- Nếu thay đổi schema, cần migration mới.

### 15.3 Khi sửa database/schema

Luôn đối chiếu 4 nơi:

- Migration.
- Model `$fillable`.
- Controller validation/request body.
- Flutter model/datasource.

Các cặp đang cần đồng bộ nhất:

- `categories.color` vs `categories.icon_color`.
- `saving_goals.name/target_date/color` vs `goal_name/deadline/status`.
- `transactions.user_id`.
- `budgets.alert_threshold`.
- Category type enum.

## 16. Roadmap đề xuất

Ưu tiên 1: Sửa lỗi gây hỏng API ngay.

- Implement `updateSettings`.
- Implement `getSummary`.
- Implement `joinChallenge`.

Ưu tiên 2: Đồng bộ schema/API/frontend.

- Sửa saving goals.
- Sửa category color/type.
- Quyết định transaction có `user_id` hay không.
- Sửa budget threshold.

Ưu tiên 3: Hoàn thiện feature người dùng thấy.

- Logout.
- Account/profile/settings.
- Notifications.
- Saving goals.
- Gamification thật.
- AI tasks thật.
- Transaction edit/delete UI.

Ưu tiên 4: Chuẩn hóa kiến trúc.

- Refactor Wallet/Budget/Report để đi qua repository/usecase hoặc loại bỏ dead code.
- Tạo Form Requests.
- Tạo API Resources.
- Thêm Policies.
- Tắt DevicePreview trong production.
- Xóa debug prints.

Ưu tiên 5: Test.

- Laravel API tests cho auth, wallet, transaction, budget, report.
- Flutter bloc tests cho Auth/Transaction/Budget/Wallet.
- Widget tests cho login/dashboard cơ bản.

## 17. Checklist nhanh cho AI Agent mới

Trước khi sửa code:

- Đọc `AI_CONTEXT.md`.
- Nếu cần chi tiết API, đọc `API_MAP.md`.
- Nếu cần schema, đọc `DATABASE_ANALYSIS.md`.
- Nếu cần map feature, đọc `FEATURE_MAP.md`.
- Nếu cần tổng quan kiến trúc, đọc `PROJECT_ANALYSIS.md`.

Khi nhận task:

- Xác định task thuộc frontend, backend, database hay full-stack.
- Xác định feature liên quan.
- Kiểm tra route/API/model/schema tương ứng.
- Kiểm tra code hiện tại có đang hard-code/mock không.
- Tránh sửa lan rộng nếu không cần.
- Không tự ý đổi schema nếu chỉ cần sửa UI.
- Nếu đổi API response, cập nhật Flutter model tương ứng.

## 18. Tóm tắt ngắn gọn

Dự án là app quản lý tài chính cá nhân có AI coaching, gồm Flutter frontend và Laravel backend. Các module chính đã hình thành: auth, ví, danh mục, giao dịch, ngân sách, báo cáo, AI coaching, notification, gamification, saving goals. Hệ thống đã chạy được nhiều luồng cốt lõi như login, tạo ví, tạo giao dịch, tạo ngân sách, báo cáo và AI review.

Rủi ro lớn nhất hiện tại là sự chưa đồng bộ giữa frontend/backend/database: route thiếu method, field schema lệch, type enum chưa thống nhất, một số module chỉ có backend hoặc UI mock. Trước khi phát triển thêm, nên ưu tiên sửa các điểm lệch này để tránh lỗi dây chuyền.

