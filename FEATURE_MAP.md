# FEATURE MAP

## 1. Mục tiêu tài liệu

File này map các chức năng từ UI Flutter đến backend Laravel và database. Trọng tâm là xác định:

- Feature đã có.
- File frontend/backend liên quan.
- API đang dùng.
- Bảng database liên quan.
- Trạng thái hoàn thiện.
- Khoảng thiếu/TODO/code chưa dùng.

## 2. Feature: Authentication

### Mục đích

Cho phép user đăng ký, đăng nhập, nhận token Sanctum và dùng token cho request protected.

### Frontend

UI:

- `Frontend/lib/feature/auth/presentation/pages/login_page.dart`.
- `Frontend/lib/feature/auth/presentation/pages/register_page.dart`.

State:

- `Frontend/lib/feature/auth/presentation/bloc/auth_bloc.dart`.
- `Frontend/lib/feature/auth/presentation/bloc/auth_event.dart`.
- `Frontend/lib/feature/auth/presentation/bloc/auth_state.dart`.

Domain:

- `Frontend/lib/feature/auth/domain/entities/auth_entity.dart`.
- `Frontend/lib/feature/auth/domain/repository/auth_repository.dart`.
- `Frontend/lib/feature/auth/domain/usecase/auth_usecase.dart`.

Data:

- `Frontend/lib/feature/auth/data/datasource/auth_datasource.dart`.
- `Frontend/lib/feature/auth/data/repository_impl/auth_repository_impl.dart`.
- `Frontend/lib/feature/auth/data/models/auth_model.dart`.

### Backend

- `Backend/routes/api.php`.
- `Backend/app/Http/Controllers/Api/AuthController.php`.
- `Backend/app/Models/User.php`.
- `Backend/database/migrations/2026_04_09_181401_create_users_table.php`.
- `Backend/database/migrations/2026_04_09_193231_create_personal_access_tokens_table.php`.

### API

- `POST /api/login`.
- `POST /api/register`.
- `POST /api/logout`.
- `GET /api/user`.

### Database

- `users`.
- `personal_access_tokens`.

### Luồng dữ liệu

1. `LoginPage` hoặc `RegisterPage` dispatch event.
2. `AuthBloc` gọi `AuthUsecase`.
3. `AuthRepositoryImpl` gọi `AuthDatasource`.
4. `Dio` gửi request tới Laravel.
5. `AuthController` validate, đọc/ghi `users`, tạo Sanctum token.
6. Flutter nhận `access_token`, lưu vào `SharedPreferences`.
7. `ApiInterceptor` tự gắn token cho request sau.

### Trạng thái

- Hoàn thiện cơ bản cho login/register.
- Logout backend có, frontend chưa thấy UI gọi.
- Register tự login bằng token nhưng `RegisterPage` listener có bug so sánh `state == AuthSuccess` thay vì `state is AuthSuccess`.
- Chưa có auto-login/session restore khi mở app lại.

## 3. Feature: Wallet

### Mục đích

Quản lý nhiều ví của user, làm nguồn cho giao dịch và tổng số dư.

### Frontend

UI:

- `Frontend/lib/feature/wallet/presentation/pages/wallet_page.dart`.
- `Frontend/lib/feature/wallet/presentation/widgets/add_wallet_bottom_sheet.dart`.
- Wallet section trong `Frontend/lib/feature/transaction/presentation/pages/dashboard_page.dart`.

State:

- `Frontend/lib/feature/wallet/presentation/bloc/wallet_bloc.dart`.
- `Frontend/lib/feature/wallet/presentation/bloc/wallet_event.dart`.
- `Frontend/lib/feature/wallet/presentation/bloc/wallet_state.dart`.

Domain/Data:

- `Frontend/lib/feature/wallet/domain/entities/wallet_entity.dart`.
- `Frontend/lib/feature/wallet/domain/repository/wallet_repository.dart`.
- `Frontend/lib/feature/wallet/domain/usecase/get_wallets_usecase.dart`.
- `Frontend/lib/feature/wallet/data/models/wallet_model.dart`.
- `Frontend/lib/feature/wallet/data/datasource/wallet_datasource.dart`.
- `Frontend/lib/feature/wallet/data/repository_impl/wallet_repository_impl.dart`.

### Backend

- `Backend/app/Http/Controllers/Api/WalletController.php`.
- `Backend/app/Models/Wallet.php`.
- `Backend/database/migrations/2026_04_09_181409_create_wallets_table.php`.

### API

- `GET /api/wallets`.
- `POST /api/wallets`.
- `GET /api/wallets/{id}`.
- `PUT/PATCH /api/wallets/{id}`.
- `DELETE /api/wallets/{id}`.

### Database

- `wallets`.
- Liên quan gián tiếp: `transactions`.

### Luồng dữ liệu

1. `DashboardPage.initState` dispatch `FetchWallets`.
2. `WalletBloc` gọi `Dio.get(AppConstants.wallets)`.
3. `WalletController@index` lấy wallets theo `user_id`.
4. Flutter parse `WalletModel`.
5. Dashboard render danh sách ví ngang và số dư.

Tạo ví:

1. User mở `AddWalletBottomSheet`.
2. Dispatch `CreateWallet`.
3. `WalletBloc` POST `/wallets`.
4. Laravel tạo wallet với `current_balance = initial_balance`.
5. BLoC fetch lại wallets.

### Trạng thái

- List/create hoạt động.
- Backend update/delete có.
- Frontend update/delete chưa implement.
- `WalletRepositoryImpl` có method `getWalletById`, `updateWallet`, `deleteWallet` ném `UnimplementedError`.
- App hiện inject `WalletBloc(dio: dio)` trực tiếp, chưa dùng repository/usecase wallet.

## 4. Feature: Category

### Mục đích

Danh mục phân loại thu/chi, dùng cho giao dịch, ngân sách và báo cáo.

### Frontend

State/Data:

- `Frontend/lib/feature/category/presentation/bloc/category_bloc.dart`.
- `Frontend/lib/feature/category/data/datasource/category_remote_data_source.dart`.
- `Frontend/lib/feature/category/data/repository_impl/category_repository_impl.dart`.
- `Frontend/lib/feature/category/data/models/category_model.dart`.
- `Frontend/lib/feature/category/domain/entities/category_entity.dart`.
- `Frontend/lib/feature/category/domain/repository/category_repository.dart`.

UI usage:

- `Frontend/lib/feature/transaction/presentation/widgets/add_transaction_bottom_sheet.dart`.
- `Frontend/lib/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart` hiện vẫn dùng category hard-code, chưa dùng `CategoryBloc`.

### Backend

- `Backend/app/Http/Controllers/Api/CategoryController.php`.
- `Backend/app/Models/Category.php`.
- `Backend/database/migrations/2026_04_09_181415_create_categories_table.php`.

### API

- `GET /api/categories`.
- `POST /api/categories`.
- `GET /api/categories/{id}`.
- `PUT/PATCH /api/categories/{id}`.
- `DELETE /api/categories/{id}`.

### Database

- `categories`.
- Liên quan:
  - `transactions.category_id`.
  - `budgets.category_id`.

### Luồng dữ liệu

1. `main.dart` tạo `CategoryBloc` với `CategoryRepositoryImpl`.
2. `CategoryRemoteDataSourceImpl` gọi `GET /categories`.
3. Backend trả `Category::all()`.
4. Flutter parse `CategoryModel`.
5. Add transaction UI lọc danh mục theo type.

### Trạng thái

- Load category hoạt động.
- CRUD backend có nhưng frontend mới dùng read/list.
- Chưa lọc categories theo user trong backend.
- Có lệch `color` vs `icon_color`.
- Có lệch type giữa `income/expense`, `Thu/Chi`, `Thu nhập/Chi phí`.

## 5. Feature: Transaction

### Mục đích

Ghi nhận thu/chi, cập nhật ví, cập nhật ngân sách, cung cấp dữ liệu dashboard/report/AI.

### Frontend

UI:

- `Frontend/lib/feature/transaction/presentation/pages/dashboard_page.dart`.
- `Frontend/lib/feature/transaction/presentation/widgets/add_transaction_bottom_sheet.dart`.

State:

- `Frontend/lib/feature/transaction/presentation/bloc/transaction_bloc.dart`.
- `Frontend/lib/feature/transaction/presentation/bloc/transaction_event.dart`.
- `Frontend/lib/feature/transaction/presentation/bloc/transaction_state.dart`.

Domain:

- `Frontend/lib/feature/transaction/domain/entities/transaction_entity.dart`.
- `Frontend/lib/feature/transaction/domain/repository/transaction_repository.dart`.
- `Frontend/lib/feature/transaction/domain/usecase/get_transactions_usecase.dart`.
- `Frontend/lib/feature/transaction/domain/usecase/create_transaction_usecase.dart`.
- `Frontend/lib/feature/transaction/domain/usecase/update_transaction_usecase.dart`.
- `Frontend/lib/feature/transaction/domain/usecase/delete_transaction_usecase.dart`.

Data:

- `Frontend/lib/feature/transaction/data/datasource/transaction_datasource.dart`.
- `Frontend/lib/feature/transaction/data/repository_impl/transaction_repository_impl.dart`.
- `Frontend/lib/feature/transaction/data/models/transaction_model.dart`.

### Backend

- `Backend/app/Http/Controllers/Api/TransactionController.php`.
- `Backend/app/Services/TransactionService.php`.
- `Backend/app/Models/Transaction.php`.
- `Backend/app/Models/Wallet.php`.
- `Backend/app/Models/Budget.php`.

### API

- `GET /api/transactions`.
- `POST /api/transactions`.
- `GET /api/transactions/{id}`.
- `PUT/PATCH /api/transactions/{id}`.
- `DELETE /api/transactions/{id}`.
- `GET /api/transactions/summary` khai báo nhưng thiếu method.

### Database

- `transactions`.
- `wallets`.
- `budgets`.
- `categories`.
- `notifications` gián tiếp khi budget alert.

### Luồng dữ liệu

Fetch:

1. `DashboardPage.initState` dispatch `FetchTransactions`.
2. `TransactionBloc` gọi `GetTransactionsUseCase`.
3. `TransactionRepositoryImpl` gọi `TransactionDatasource.getTransactions`.
4. Backend lấy giao dịch theo wallets của user.
5. Dashboard tính tổng thu, tổng chi, tổng số dư từ list transaction.

Create:

1. User nhập giao dịch trong `AddTransactionBottomSheet`.
2. Có thể chọn ảnh hóa đơn, Flutter gọi `google_generative_ai` để parse amount/note.
3. Dispatch `AddTransactionSubmitted`.
4. POST `/api/transactions`.
5. Backend tạo transaction, cập nhật wallet và budget.
6. Flutter reload transactions, wallets, budgets/report.

### Trạng thái

- CRUD frontend/backend có.
- Dashboard hiển thị recent transactions.
- Update/delete có BLoC/usecase/datasource nhưng UI thao tác sửa/xóa chưa thấy rõ trong screen hiện tại.
- Endpoint summary thiếu implementation.
- `TransactionDatasource` còn `print` debug.
- Store controller không gọi `TransactionService@createTransaction`, nên logic cộng điểm gamification trong service không chạy khi tạo transaction qua API hiện tại.

## 6. Feature: Budget

### Mục đích

Thiết lập hạn mức chi theo category và thời gian, theo dõi số tiền đã chi.

### Frontend

UI:

- `Frontend/lib/feature/budget/presentation/pages/budget_page.dart`.
- `Frontend/lib/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart`.
- `Frontend/lib/feature/budget/presentation/widgets/budget_card.dart`.
- Budget section trong `DashboardPage`.

State:

- `Frontend/lib/feature/budget/presentation/bloc/budget_bloc.dart`.
- `Frontend/lib/feature/budget/presentation/bloc/budget_event.dart`.
- `Frontend/lib/feature/budget/presentation/bloc/budget_state.dart`.

Domain/Data:

- `Frontend/lib/feature/budget/domain/entities/budget_entity.dart`.
- `Frontend/lib/feature/budget/domain/repository/budget_repository.dart`.
- `Frontend/lib/feature/budget/domain/usecase/get_budgets_usecase.dart`.
- `Frontend/lib/feature/budget/data/models/budget_model.dart`.
- `Frontend/lib/feature/budget/data/datasource/budget_datasource.dart`.
- `Frontend/lib/feature/budget/data/repository_impl/budget_repository_impl.dart`.

### Backend

- `Backend/app/Http/Controllers/Api/BudgetController.php`.
- `Backend/app/Models/Budget.php`.
- `Backend/database/migrations/2026_04_09_182108_create_budgets_table.php`.

### API

- `GET /api/budgets`.
- `POST /api/budgets`.
- `GET /api/budgets/{id}`.
- `PUT/PATCH /api/budgets/{id}`.
- `DELETE /api/budgets/{id}`.

### Database

- `budgets`.
- Liên quan:
  - `categories`.
  - `transactions`.
  - `notifications`.

### Luồng dữ liệu

1. `main.dart` tạo `BudgetBloc(dio: dio)..add(FetchBudgets())`.
2. `BudgetBloc` GET `/budgets`.
3. `BudgetController@index` trả budgets theo user.
4. Dashboard hiển thị tối đa 2 budget bằng `BudgetCard`.
5. Tạo budget từ `AddBudgetBottomSheet`, tự tính đầu/cuối tháng hiện tại.

### Trạng thái

- List/create hoạt động.
- Backend show/update/delete có.
- Frontend update/delete chưa có UI.
- `BudgetRepositoryImpl`/`BudgetDataSource` tồn tại nhưng BLoC đang gọi Dio trực tiếp.
- Add budget đang dùng category hard-code, không dùng category API.
- Threshold alert cần sửa logic phần trăm.

## 7. Feature: Report

### Mục đích

Tổng hợp chi tiêu theo category và vẽ biểu đồ.

### Frontend

UI:

- `Frontend/lib/feature/transaction/presentation/pages/report_page.dart`.

State/Data:

- `Frontend/lib/feature/transaction/presentation/bloc/report_bloc.dart`.
- `Frontend/lib/feature/transaction/data/models/category_spending_model.dart`.

Library:

- `fl_chart`.

### Backend

- `Backend/app/Http/Controllers/Api/ReportController.php`.
- `Backend/app/Models/Transaction.php`.

### API

- `GET /api/reports/spending-by-category`.

### Database

- `transactions`.
- `wallets`.
- `categories`.

### Luồng dữ liệu

1. `ReportBloc` dispatch `FetchCategorySpending`.
2. Dio GET `/reports/spending-by-category`.
3. Backend lọc transaction theo wallet của user và tháng hiện tại.
4. Group by category, sum amount.
5. Flutter parse `CategorySpendingModel`.
6. `ReportPage` render pie chart.

### Trạng thái

- Hoạt động cơ bản.
- Backend đang comment điều kiện `where('type', 'Chi')`, nên report có thể cộng cả thu nhập.
- Report chỉ theo tháng hiện tại, chưa có filter thời gian.

## 8. Feature: AI Coaching

### Mục đích

Sinh nhận xét tài chính dựa trên số dư ví, thu/chi tháng hiện tại và ghi chú giao dịch gần đây.

### Frontend

UI:

- `Frontend/lib/feature/aicoaching/presentation/pages/aicoaching_page.dart`.
- AI card hard-code trong `DashboardPage`.

State:

- `Frontend/lib/feature/aicoaching/presentation/bloc/aicoaching_bloc.dart`.
- `Frontend/lib/feature/aicoaching/presentation/bloc/aicoaching_event.dart`.
- `Frontend/lib/feature/aicoaching/presentation/bloc/aicoaching_state.dart`.

Domain/Data:

- `Frontend/lib/feature/aicoaching/domain/entities/aicoaching_entity.dart`.
- `Frontend/lib/feature/aicoaching/domain/repository/aicoaching_repository.dart`.
- `Frontend/lib/feature/aicoaching/domain/usecase/get_coachings_usecase.dart`.
- `Frontend/lib/feature/aicoaching/data/datasource/aicoaching_datasource.dart`.
- `Frontend/lib/feature/aicoaching/data/datasource/ai_datasource.dart`.
- `Frontend/lib/feature/aicoaching/data/repository_impl/aicoaching_repository_impl.dart`.
- `Frontend/lib/feature/aicoaching/data/models/aicoaching_model.dart`.

### Backend

- `Backend/app/Http/Controllers/Api/AIController.php`.
- `Backend/app/Models/AI_Review.php`.
- `Backend/app/Models/AI_Task.php`.
- Migrations: `ai_reviews`, `ai_tasks`.

### API

- `GET /api/ai/reviews`.
- `GET /api/ai/tasks`.
- `POST /api/ai/tasks/{id}/complete`.

### Database

- `ai_reviews`.
- `ai_tasks`.
- Dữ liệu đầu vào AI realtime:
  - `wallets`.
  - `transactions`.

### Luồng dữ liệu

1. `AiCoachingPage.initState` dispatch `LoadAICoachingEvent`.
2. `AICoachingBloc` gọi `GetCoachingsUseCase`.
3. `AICoachingRepositoryImpl` gọi `AIDatasource.getCoachings`.
4. Dio GET `/ai/reviews`.
5. `AIController@getReviews` tổng hợp dữ liệu user và gọi Gemini Laravel facade.
6. Flutter parse `AICoachingModel` và hiển thị review.

### Trạng thái

- AI review động đã có.
- Dashboard AI card vẫn hard-code.
- AI tasks backend hard-code, frontend task card cũng hard-code, chưa đồng bộ DB.
- `AIDatasource` chỉ implement `getCoachings`; các method khác ném `UnimplementedError`.
- `AIController` không persist review vào `ai_reviews`.
- Flutter OCR hóa đơn dùng `google_generative_ai` với `apiKey` rỗng trong `AddTransactionBottomSheet`, nên tính năng scan cần cấu hình key hoặc chuyển sang backend.

## 9. Feature: Notification

### Mục đích

Thông báo budget alert và achievement.

### Frontend

- Chưa thấy feature Flutter riêng.
- Dashboard có icon notification trong wallet card nhưng không có action/API.

### Backend

- `Backend/app/Http/Controllers/Api/NotificationController.php`.
- `Backend/app/Models/Notification.php`.
- `Backend/database/migrations/2026_04_09_182212_create_notifications_table.php`.
- `TransactionService` tạo budget alert.
- `GamificationService` tạo achievement notification.

### API

- `GET /api/notifications`.
- `PUT /api/notifications/{id}/read`.

### Database

- `notifications`.

### Trạng thái

- Backend có list/mark read.
- Frontend chưa triển khai.
- Chưa có realtime/push notification.

## 10. Feature: Saving Goals

### Mục đích

Theo dõi mục tiêu tiết kiệm.

### Frontend

- Chưa có feature folder riêng.
- Có constant `AppConstants.savingGoals`.

### Backend

- `Backend/app/Http/Controllers/Api/SavingGoalController.php`.
- `Backend/app/Models/SavingGoal.php`.
- `Backend/database/migrations/2026_04_09_182141_create_saving_goals_table.php`.

### API

- `GET /api/saving-goals`.
- `POST /api/saving-goals`.
- `GET /api/saving-goals/{id}`.
- `PUT/PATCH /api/saving-goals/{id}`.
- `DELETE /api/saving-goals/{id}`.

### Database

- `saving_goals`.

### Trạng thái

- Backend CRUD có nhưng field mismatch nghiêm trọng giữa controller và schema.
- Frontend chưa triển khai.
- AI prompt có nhắc mục tiêu mua xe Xpander nhưng không đọc `saving_goals`.

## 11. Feature: Gamification

### Mục đích

Điểm thưởng, badges, challenges, task tích lũy.

### Frontend

- Task cards hard-code trong:
  - `Frontend/lib/feature/transaction/presentation/pages/dashboard_page.dart`.
  - `Frontend/lib/feature/aicoaching/presentation/pages/aicoaching_page.dart`.
- Chưa thấy datasource/repository/BLoC riêng cho badges/challenges.

### Backend

- `Backend/app/Http/Controllers/Api/GamificationController.php`.
- `Backend/app/Services/GamificationService.php`.
- Models:
  - `Badge`.
  - `Challenge`.
  - `User_Badge`.
  - `User_Challenge`.
- Migrations:
  - `badges`.
  - `user_badges`.
  - `challenges`.
  - `user_challenges`.

### API

- `GET /api/badges`.
- `GET /api/challenges`.
- `POST /api/challenges/{id}/join`.

### Database

- `users.total_points`.
- `badges`.
- `user_badges`.
- `challenges`.
- `user_challenges`.
- `notifications`.

### Luồng dữ liệu backend dự kiến

1. Service cộng `users.total_points`.
2. Check điều kiện badge.
3. Attach badge vào `user_badges`.
4. Tạo notification.

### Trạng thái

- Backend model/schema/service đã có.
- API badges/challenges list có.
- `joinChallenge` thiếu implementation.
- Frontend chưa gọi API.
- `TransactionController@store` không gọi gamification service, nên tạo giao dịch không cộng điểm trong luồng hiện tại.

## 12. Feature: User Settings/Profile

### Mục đích

Quản lý hồ sơ, theme, language, reminder, enable AI.

### Frontend

- Tab Account trong `DashboardPage` đang là placeholder: "Tính năng Tài khoản đang phát triển".
- Chưa thấy screen profile/settings.

### Backend

- Model: `Backend/app/Models/UserSetting.php`.
- Migration: `Backend/database/migrations/2026_04_09_182217_create_user_settings_table.php`.
- Route: `PUT /api/user/settings`.

### Database

- `user_settings`.
- `users`.

### Trạng thái

- Schema/model có.
- Route có.
- Controller method thiếu.
- Frontend thiếu.

## 13. Feature status summary

Hoàn thiện tương đối:

- Auth login/register.
- Wallet list/create.
- Category list.
- Transaction list/create/update/delete ở tầng API/BLoC.
- Budget list/create.
- Spending report.
- AI review động.

Đang phát triển:

- Account/profile/settings.
- Gamification UI/API integration.
- AI tasks persistence.
- Notifications frontend.
- Saving goals frontend/backend field sync.
- Wallet update/delete frontend.
- Budget update/delete frontend.
- Category CRUD frontend.
- Report filters.

TODO/code chưa dùng:

- `WalletRepositoryImpl` chưa inject và có `UnimplementedError`.
- `BudgetRepositoryImpl`/`BudgetDataSource` chưa có concrete API datasource được dùng.
- `AIDatasource` CRUD methods chưa implement.
- `AppConstants.aiReviews = '/ai-reviews'` và `AppConstants.aiTasks = '/ai-tasks'` không khớp route Laravel hiện tại.
- `TransactionDatasource` còn debug print.
- `AddBudgetBottomSheet` category hard-code.
- `DashboardPage` AI card và gamification tasks hard-code.

Module còn thiếu:

- Frontend notifications.
- Frontend saving goals.
- Frontend gamification.
- Frontend profile/settings.
- Backend Form Requests.
- Backend API Resources.
- Backend repository layer nếu muốn architecture nhất quán.
- Backend Jobs/Events cho AI/notification async.
- Test cases thực tế cho Laravel API và Flutter BLoC/widget.

## 14. Luồng dữ liệu tổng quát Flutter UI -> Repository -> API -> Laravel -> Database

```text
Flutter UI
  -> BLoC event
  -> UseCase hoặc BLoC gọi Dio trực tiếp
  -> Repository/DataSource
  -> DioClient + ApiInterceptor
  -> Laravel routes/api.php
  -> Controller
  -> Service nếu có
  -> Eloquent Model
  -> Database
  -> JSON response
  -> Model.fromJson
  -> BLoC state
  -> UI rebuild
```

Các feature đang đi đúng Clean Architecture hơn:

- Auth.
- Transaction.
- Category.
- AI Coaching cho read flow.

Các feature đang bypass một phần architecture:

- Wallet: BLoC gọi Dio trực tiếp, repository chưa được dùng.
- Budget: BLoC gọi Dio trực tiếp, datasource/repository chưa được dùng trong app.
- Report: BLoC gọi Dio trực tiếp và model nằm trong transaction feature.

## 15. Đề xuất ưu tiên kiến trúc

Ưu tiên 1: Sửa endpoint khai báo nhưng thiếu handler:

- `AuthController@updateSettings`.
- `TransactionController@getSummary`.
- `GamificationController@joinChallenge`.

Ưu tiên 2: Đồng bộ schema/API:

- `saving_goals` field names.
- `categories.icon_color` vs `color`.
- `transactions.user_id` quyết định có hay không.
- category type enum.
- budget threshold calculation.

Ưu tiên 3: Hoàn thiện module đang thiếu:

- Profile/settings frontend/backend.
- Notifications frontend.
- Saving goals frontend.
- Gamification frontend.

Ưu tiên 4: Chuẩn hóa architecture:

- Cho Wallet/Budget/Report đi qua repository/usecase giống Transaction/Auth.
- Tạo Form Requests cho validation.
- Tạo API Resources để response ổn định.
- Thêm tests cho API quan trọng và BLoC.

