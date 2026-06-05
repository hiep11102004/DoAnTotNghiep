# API MAP

## 1. Base URL

Frontend đang cấu hình API base URL tại `Frontend/lib/core/constants/app_constants.dart`:

- `http://192.168.0.101:8000/api`

`DioClient` tại `Frontend/lib/core/network/dio_client.dart` set `baseUrl` này cho toàn bộ request. `ApiInterceptor` tại `Frontend/lib/core/network/api_interceptor.dart` tự động gắn:

- `Authorization: Bearer <token>` nếu `SharedPreferences` có key `token`.
- `Accept: application/json`.

Backend khai báo route API tại `Backend/routes/api.php`. Laravel tự prefix `/api` cho file route này.

## 2. Public endpoints

### POST `/api/login`

- Backend: `Backend/app/Http/Controllers/Api/AuthController.php`, method `login`.
- Frontend gọi tại: `Frontend/lib/feature/auth/data/datasource/auth_datasource.dart`.
- Request body Flutter:
  - `username`: email hoặc username.
  - `password`.
- Backend validation:
  - `username` required.
  - `password` required.
- Response thành công:
  - `status`.
  - `access_token`.
  - `token_type`.
  - `user`.
- Ghi chú: Login tìm user bằng `username` hoặc `email`.

### POST `/api/register`

- Backend: `AuthController@register`.
- Frontend gọi tại: `AuthDatasource.register`.
- Request body Flutter:
  - `full_name`.
  - `username`: lấy từ phần trước `@` của email.
  - `email`.
  - `password`.
- Backend validation:
  - `full_name` required string max 255.
  - `username` required unique.
  - `email` required email unique.
  - `password` required min 6.
- Response thành công: tương tự login, có token để đăng nhập ngay.

## 3. Protected endpoints

Tất cả endpoint dưới đây nằm trong group:

- Middleware: `auth:sanctum`.
- File: `Backend/routes/api.php`.

### GET `/api/user`

- Backend: closure trong `routes/api.php`.
- Frontend: chưa thấy gọi.
- Response: user hiện tại từ Sanctum token.

### POST `/api/logout`

- Backend: `AuthController@logout`.
- Frontend: có constant `AppConstants.logout`, chưa thấy UI gọi.
- Behavior: xóa current access token.

### PUT `/api/user/settings`

- Backend route: `AuthController@updateSettings`.
- Trạng thái: route đã khai báo nhưng `AuthController` hiện không có method `updateSettings`.
- DB liên quan: `user_settings`.
- Frontend: chưa thấy gọi.
- Rủi ro: endpoint sẽ lỗi runtime nếu được gọi.

## 4. Wallet endpoints

Route khai báo:

- `Route::apiResource('wallets', WalletController::class)`.
- Controller: `Backend/app/Http/Controllers/Api/WalletController.php`.
- Model: `Backend/app/Models/Wallet.php`.
- Migration: `Backend/database/migrations/2026_04_09_181409_create_wallets_table.php`.

### GET `/api/wallets`

- Method: `WalletController@index`.
- Frontend gọi tại:
  - `Frontend/lib/feature/wallet/presentation/bloc/wallet_bloc.dart`.
  - `Frontend/lib/feature/wallet/data/repository_impl/wallet_repository_impl.dart`.
- Behavior: lấy wallets theo `user_id` của user đăng nhập.
- Response: array wallet.

### POST `/api/wallets`

- Method: `WalletController@store`.
- Frontend gọi tại:
  - `WalletBloc` khi `CreateWallet`.
  - `WalletRepositoryImpl.createWallet` có code nhưng repository chưa được dùng chính trong app.
- Request body thực tế từ `WalletBloc`:
  - `name`.
  - `initial_balance`.
  - `current_balance`.
  - `type`: hard-code `Cash`.
  - `currency`: hard-code `VND`.
- Backend validation:
  - `name` required.
  - `type` required.
  - `currency` required.
  - `initial_balance` required numeric min 0.
- Ghi chú: backend không nhận `current_balance` từ request, mà set bằng `initial_balance`.

### GET `/api/wallets/{wallet}`

- Method: `WalletController@show`.
- Frontend: chưa thấy gọi.
- Behavior: chỉ trả wallet thuộc user hiện tại.

### PUT/PATCH `/api/wallets/{wallet}`

- Method: `WalletController@update`.
- Frontend: chưa implement luồng update.

### DELETE `/api/wallets/{wallet}`

- Method: `WalletController@destroy`.
- Frontend: chưa implement luồng delete.

## 5. Category endpoints

Route:

- `Route::apiResource('categories', CategoryController::class)`.
- Controller: `Backend/app/Http/Controllers/Api/CategoryController.php`.
- Model: `Backend/app/Models/Category.php`.
- Migration: `Backend/database/migrations/2026_04_09_181415_create_categories_table.php`.

### GET `/api/categories`

- Method: `CategoryController@index`.
- Frontend gọi tại: `Frontend/lib/feature/category/data/datasource/category_remote_data_source.dart`.
- Response: toàn bộ categories.
- Ghi chú: chưa lọc theo user. Migration cho phép `user_id` nullable để hỗ trợ category mặc định.

### POST `/api/categories`

- Method: `CategoryController@store`.
- Frontend: chưa thấy UI gọi.
- Request backend:
  - `name`.
  - `icon`.
  - `type`: `income` hoặc `expense`.
  - `color`.
- Lệch schema: migration/model có `icon_color`, không có `color`.

### GET `/api/categories/{category}`

- Method: `CategoryController@show`.
- Frontend: chưa thấy gọi.

### PUT/PATCH `/api/categories/{category}`

- Method: `CategoryController@update`.
- Frontend: chưa thấy gọi.
- Lệch schema tương tự `store`: dùng `color` thay vì `icon_color`.

### DELETE `/api/categories/{category}`

- Method: `CategoryController@destroy`.
- Frontend: chưa thấy gọi.

## 6. Transaction endpoints

Routes:

- `GET /transactions/summary` -> `TransactionController@getSummary`.
- `Route::apiResource('transactions', TransactionController::class)`.
- Controller: `Backend/app/Http/Controllers/Api/TransactionController.php`.
- Service: `Backend/app/Services/TransactionService.php`.
- Model: `Backend/app/Models/Transaction.php`.
- Migration: `Backend/database/migrations/2026_04_09_181421_create_transactions_table.php` và `2026_06_03_172200_add_type_to_transactions_table.php`.

### GET `/api/transactions/summary`

- Trạng thái: route đã khai báo nhưng `TransactionController` hiện không có method `getSummary`.
- Frontend: chưa thấy gọi.
- Rủi ro: endpoint lỗi runtime nếu gọi.

### GET `/api/transactions`

- Method: `TransactionController@index`.
- Frontend gọi tại: `Frontend/lib/feature/transaction/data/datasource/transaction_datasource.dart`.
- Behavior:
  - Lấy wallet IDs của user hiện tại.
  - Lấy transactions trong các ví đó.
  - Sort `date desc`, `id desc`.
- Response:
  - `{ "data": [transactions] }`.
- Frontend có fallback parse cả response list trực tiếp và response có `data`.

### POST `/api/transactions`

- Method: `TransactionController@store`.
- Frontend gọi tại: `TransactionDatasource.createTransaction`.
- Request từ Flutter:
  - `wallet_id`.
  - `category_id`.
  - `amount`.
  - `type`: `Thu` hoặc `Chi`.
  - `date`.
  - `note`.
  - `image_url`.
  - `status`.
  - `source`.
- Backend validation:
  - `wallet_id` required exists.
  - `category_id` required exists.
  - `amount` required numeric min 0.
  - `type` required in `Thu,Chi`.
  - `date` required date.
  - `note` nullable.
- Behavior:
  - Verify wallet thuộc user.
  - Tạo transaction trong DB transaction.
  - Cập nhật `wallet.current_balance`: `Thu` cộng, `Chi` trừ.
  - Nếu `Chi`, tìm budget cùng user/category và date trong khoảng start/end để cộng `spent_amount`.
- Lệch schema: controller gán thêm `user_id`, nhưng migration `transactions` không có `user_id`, model `Transaction::$fillable` cũng không có `user_id`.

### GET `/api/transactions/{transaction}`

- Method: `TransactionController@show`.
- Frontend: chưa thấy gọi.
- Behavior: gọi `TransactionService@getTransactionById`.
- Ghi chú: method service không kiểm tra transaction thuộc user hiện tại.

### PUT/PATCH `/api/transactions/{transaction}`

- Method: `TransactionController@update`.
- Frontend gọi tại: `TransactionDatasource.updateTransaction`.
- Behavior: gọi `TransactionService@updateTransaction`, rollback/cập nhật balance.
- Ghi chú: service tìm transaction bằng id trực tiếp, chưa verify wallet/user ownership rõ ràng.

### DELETE `/api/transactions/{transaction}`

- Method: `TransactionController@destroy`.
- Frontend gọi tại: `TransactionDatasource.deleteTransaction`.
- Behavior: gọi `TransactionService@deleteTransaction`, hoàn tác wallet balance, recalc budget.

## 7. Budget endpoints

Route:

- `Route::apiResource('budgets', BudgetController::class)`.
- Controller: `Backend/app/Http/Controllers/Api/BudgetController.php`.
- Model: `Backend/app/Models/Budget.php`.

### GET `/api/budgets`

- Method: `BudgetController@index`.
- Frontend gọi tại: `Frontend/lib/feature/budget/presentation/bloc/budget_bloc.dart`.
- Behavior: lấy budgets theo user hiện tại.

### POST `/api/budgets`

- Method: `BudgetController@store`.
- Frontend gọi tại: `BudgetBloc` khi `AddBudget`.
- Request từ Flutter:
  - `category_id`.
  - `amount_limit`.
  - `start_date`.
  - `end_date`.
- Backend chấp nhận thêm alias `amount`.
- Default `spent_amount = 0`, `alert_threshold = 80`.

### GET `/api/budgets/{budget}`

- Method: `BudgetController@show`.
- Frontend: chưa thấy gọi.

### PUT/PATCH `/api/budgets/{budget}`

- Method: `BudgetController@update`.
- Frontend: chưa thấy gọi.

### DELETE `/api/budgets/{budget}`

- Method: `BudgetController@destroy`.
- Frontend: chưa thấy gọi.

## 8. Saving goal endpoints

Route:

- `Route::apiResource('saving-goals', SavingGoalController::class)`.
- Controller: `Backend/app/Http/Controllers/Api/SavingGoalController.php`.

Endpoints được Laravel tạo:

- `GET /api/saving-goals`.
- `POST /api/saving-goals`.
- `GET /api/saving-goals/{saving_goal}`.
- `PUT/PATCH /api/saving-goals/{saving_goal}`.
- `DELETE /api/saving-goals/{saving_goal}`.

Frontend:

- Có constant `AppConstants.savingGoals`.
- Chưa thấy datasource/repository/page gọi saving goals.

Lệch schema:

- Controller dùng `name`, `target_date`, `color`.
- Migration/model dùng `goal_name`, `deadline`, `status`.

## 9. AI endpoints

Controller: `Backend/app/Http/Controllers/Api/AIController.php`.

### GET `/api/ai/reviews`

- Method: `AIController@getReviews`.
- Frontend gọi tại: `Frontend/lib/feature/aicoaching/data/datasource/ai_datasource.dart`.
- Behavior:
  - Lấy wallet IDs của user.
  - Tính tổng số dư, tổng thu/chi tháng hiện tại.
  - Lấy 5 ghi chú chi gần đây.
  - Gửi prompt tới Gemini.
  - Trả `{ status, data: { review } }`.
- Ghi chú:
  - Controller có fallback `$request->user() ? id : 1`.
  - Catch exception trả HTTP 200 với review chứa nội dung lỗi Gemini.

### GET `/api/ai/tasks`

- Method: `AIController@getTasks`.
- Frontend: chưa thấy gọi.
- Response: danh sách task hard-code.
- Chưa đọc/ghi bảng `ai_tasks`.

### POST `/api/ai/tasks/{id}/complete`

- Method: `AIController@completeTask`.
- Frontend: chưa thấy gọi.
- Response: message hard-code.
- Chưa cập nhật task status/points trong database.

## 10. Gamification endpoints

Controller: `Backend/app/Http/Controllers/Api/GamificationController.php`.

### GET `/api/badges`

- Method: `GamificationController@getMyBadges`.
- Frontend: chưa thấy gọi.
- Behavior: `$request->user()->badges()->get()`.

### GET `/api/challenges`

- Method: `GamificationController@index`.
- Frontend: chưa thấy gọi.
- Behavior: lấy challenges có `end_date >= now()`.

### POST `/api/challenges/{id}/join`

- Route khai báo tới `GamificationController@joinChallenge`.
- Trạng thái: controller chưa có method `joinChallenge`.
- Frontend: chưa thấy gọi.

## 11. Notification endpoints

Controller: `Backend/app/Http/Controllers/Api/NotificationController.php`.

### GET `/api/notifications`

- Method: `NotificationController@index`.
- Frontend: chưa thấy gọi.
- Behavior: lấy notifications theo user, sort mới nhất.

### PUT `/api/notifications/{id}/read`

- Method: `NotificationController@markAsRead`.
- Frontend: chưa thấy gọi.
- Behavior: mark `is_read = true`.

## 12. Report endpoints

Controller: `Backend/app/Http/Controllers/Api/ReportController.php`.

### GET `/api/reports/spending-by-category`

- Method: `ReportController@getSpendingByCategory`.
- Frontend gọi tại: `Frontend/lib/feature/transaction/presentation/bloc/report_bloc.dart`.
- Behavior:
  - Lọc transactions theo wallet thuộc user.
  - Lọc tháng/năm hiện tại.
  - Group by `category_id`.
  - Sum `amount`.
  - Eager load `category:id,name,icon_color`.
- Ghi chú:
  - Dòng `where('type', 'Chi')` đang bị comment, nên report có thể cộng cả thu lẫn chi.

## 13. Endpoint Flutter đang sử dụng thực tế

Các endpoint chắc chắn đang được gọi từ Flutter:

- `POST /api/login`: `AuthDatasource.login`.
- `POST /api/register`: `AuthDatasource.register`.
- `GET /api/wallets`: `WalletBloc`, `WalletRepositoryImpl`.
- `POST /api/wallets`: `WalletBloc`, `WalletRepositoryImpl`.
- `GET /api/categories`: `CategoryRemoteDataSourceImpl`.
- `GET /api/transactions`: `TransactionDatasource.getTransactions`.
- `POST /api/transactions`: `TransactionDatasource.createTransaction`.
- `PUT /api/transactions/{id}`: `TransactionDatasource.updateTransaction`.
- `DELETE /api/transactions/{id}`: `TransactionDatasource.deleteTransaction`.
- `GET /api/budgets`: `BudgetBloc`.
- `POST /api/budgets`: `BudgetBloc`.
- `GET /api/ai/reviews`: `AIDatasource`.
- `GET /api/reports/spending-by-category`: `ReportBloc`.

Các endpoint có constant nhưng chưa thấy được gọi:

- `/logout`.
- `/saving-goals`.
- `/ai-reviews`: constant cũ không khớp route thật `/ai/reviews`.
- `/ai-tasks`: constant cũ không khớp route thật `/ai/tasks`.

Các endpoint backend có nhưng frontend chưa dùng:

- `GET /api/user`.
- `PUT /api/user/settings`.
- Full update/delete/show wallet.
- Full create/update/delete/show category.
- Show budget/update/delete.
- Saving goals CRUD.
- AI tasks.
- Badges/challenges.
- Notifications.

## 14. Luồng dữ liệu tiêu biểu

### Login

1. `LoginPage` dispatch `LoginSubmitted`.
2. `AuthBloc` gọi `AuthUsecase.executeLogin`.
3. `AuthRepositoryImpl` gọi `AuthDatasource.login`.
4. Dio `POST /api/login`.
5. `AuthController@login` xác thực user/password.
6. Laravel Sanctum tạo token.
7. Flutter nhận `AuthModel`, `LoginPage` lưu token vào `SharedPreferences`.
8. Điều hướng tới `/dashboard`.

### Tạo giao dịch

1. User mở `AddTransactionBottomSheet` từ FAB trong `DashboardPage`.
2. UI chọn wallet/category, nhập amount/type/date/note hoặc scan hóa đơn bằng Gemini client.
3. Dispatch `AddTransactionSubmitted`.
4. `TransactionBloc` gọi `CreateTransactionUseCase`.
5. `TransactionRepositoryImpl` build `TransactionModel`.
6. `TransactionDatasource` gọi `POST /api/transactions`.
7. `ApiInterceptor` gắn token.
8. `TransactionController@store` validate, kiểm tra wallet thuộc user.
9. Backend tạo transaction, cập nhật wallet balance, cập nhật budget nếu là chi.
10. Flutter reload transactions, wallet, budget/report ở các vị trí liên quan.

### Báo cáo chi tiêu

1. `ReportBloc` dispatch `FetchCategorySpending` khi app khởi tạo và sau tạo transaction.
2. Dio `GET /api/reports/spending-by-category`.
3. `ReportController` group transaction theo category.
4. Flutter parse `CategorySpendingModel`.
5. `ReportPage` vẽ pie chart bằng `fl_chart`.

