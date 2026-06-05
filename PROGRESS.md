# PROGRESS.md — Nhật ký tiến độ dự án

> Cập nhật lần cuối: 06/06/2026 (Ưu tiên 4 + tính năng bổ sung hoàn thành)  
> Dự án: Financial AI Coaching (Flutter + Laravel)

---

## ✅ ĐÃ LÀM

### Ưu tiên 1 — Sửa lỗi gây hỏng API (route có nhưng method thiếu → 500 error)

| # | Việc đã làm | File backend |
|---|-------------|-------------|
| 1 | Implement `updateSettings` cho `PUT /api/user/settings` | `AuthController.php` |
| 2 | Implement `getSummary` cho `GET /api/transactions/summary` | `TransactionController.php` |
| 3 | Implement `joinChallenge` cho `POST /api/challenges/{id}/join` | `GamificationController.php` |

---

### Ưu tiên 2 — Đồng bộ Schema / API / Frontend

| # | Việc đã làm | File liên quan |
|---|-------------|---------------|
| 1 | Sửa field names `SavingGoalController`: `name`→`goal_name`, `target_date`→`deadline`, xóa `color` | `SavingGoalController.php` |
| 2 | Sửa `CategoryController`: `color`→`icon_color` | `CategoryController.php` |
| 3 | Sửa budget threshold bug: `$limit * $threshold` → `$limit * ($threshold / 100)` (DB lưu integer 80, không phải 0.8) | `TransactionService.php` |
| 4 | Thêm cột `user_id` vào bảng `transactions` (migration + backfill từ wallet) | migration mới, `Transaction.php` |
| 5 | Thêm `user_id` vào `Transaction.$fillable` + quan hệ `belongsTo(User)` | `Transaction.php` |
| 6 | Đơn giản hoá query trong `index()` và `getSummary()` dùng `user_id` trực tiếp | `TransactionController.php` |
| 7 | Fix `DatabaseSeeder`: category type `'Chi phí'/'Thu nhập'` → `'expense'/'income'` để khớp Flutter | `DatabaseSeeder.php` |
| 8 | Fix `DatabaseSeeder`: bổ sung `user_id` và `type` vào dữ liệu transactions mẫu | `DatabaseSeeder.php` |
| 9 | Thêm `AppConstants` còn thiếu: `userProfile`, `userSettings`, `notifications`, `aiTasks`, `badges`, `challenges`, `transactionsSummary` | `app_constants.dart` |

---

### Ưu tiên 3 — Hoàn thiện tính năng người dùng thấy

#### 3.1 Logout
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Thêm `logout()` vào datasource | `auth_datasource.dart` |
| 2 | Thêm abstract `logout()` vào repository interface | `auth_repository.dart` |
| 3 | Implement `logout()` trong repository | `auth_repository_impl.dart` |
| 4 | Thêm `executeLogout()` vào usecase | `auth_usecase.dart` |
| 5 | Thêm event `LogoutSubmitted` | `auth_event.dart` |
| 6 | Thêm state `AuthLoggedOut` | `auth_state.dart` |
| 7 | Thêm handler logout trong BLoC (gọi API → clear SharedPreferences → emit `AuthLoggedOut`) | `auth_bloc.dart` |

#### 3.2 Account / Profile / Settings
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Lưu `user_name`, `user_email`, `user_id` vào SharedPreferences sau login | `login_page.dart` |
| 2 | Tạo `ProfilePage`: avatar chữ cái, hiển thị tên/email, menu điều hướng (Saving Goals, Notifications), nút Đăng xuất có confirm dialog | `profile_page.dart` (mới) |
| 3 | Thay placeholder "Tính năng đang phát triển" ở tab 4 Dashboard bằng `ProfilePage` | `dashboard_page.dart` |

#### 3.3 Register page
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Sửa bug listener `state == AuthSuccess` → `state is AuthSuccess` | `register_page.dart` |
| 2 | Sau đăng ký thành công: lưu token/user info vào SharedPreferences và điều hướng thẳng vào `/dashboard` (không cần đăng nhập lại) | `register_page.dart` |

#### 3.4 Transaction Edit / Delete
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | **Fix bug**: sau `DeleteTransactionPressed` giờ tự động gọi `FetchTransactions` (trước đây list không cập nhật sau xóa) | `transaction_bloc.dart` |
| 2 | Tạo `EditTransactionBottomSheet`: pre-fill dữ liệu từ entity, fire `UpdateTransactionSubmitted` | `edit_transaction_bottom_sheet.dart` (mới) |
| 3 | Thêm **swipe-to-delete** (Dismissible) với confirm dialog trên từng giao dịch trong dashboard | `dashboard_page.dart` |
| 4 | Thêm **tap-to-edit** mở `EditTransactionBottomSheet` khi nhấn vào giao dịch | `dashboard_page.dart` |

#### 3.5 AI Tasks
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Thêm `getTasks()` và `completeTask()` vào datasource | `ai_datasource.dart` |
| 2 | Tạo model `AITaskModel` | `aicoaching_model.dart` |
| 3 | Thêm events: `LoadAITasksEvent`, `CompleteAITaskEvent` | `aicoaching_event.dart` |
| 4 | Thêm states: `AITasksLoading`, `AITasksLoaded`, `AITasksError` | `aicoaching_state.dart` |
| 5 | Thêm handlers trong BLoC | `aicoaching_bloc.dart` |
| 6 | Thay card nhiệm vụ hardcode bằng `BlocBuilder` đọc real data từ `GET /ai/tasks` | `aicoaching_page.dart` |

#### 3.6 Gamification (Challenges)
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Thêm `getChallenges()` và `joinChallenge()` vào datasource | `ai_datasource.dart` |
| 2 | Tạo model `ChallengeModel` | `aicoaching_model.dart` |
| 3 | Thêm events: `LoadChallengesEvent`, `JoinChallengeEvent` | `aicoaching_event.dart` |
| 4 | Thêm states: `ChallengesLoading`, `ChallengesLoaded`, `ChallengesError`, `ChallengeActionSuccess` | `aicoaching_state.dart` |
| 5 | Thêm handlers trong BLoC | `aicoaching_bloc.dart` |
| 6 | Thay card "Thử thách tích lũy" hardcode bằng danh sách real từ `GET /challenges` + nút "Tham gia" | `aicoaching_page.dart` |

#### 3.7 Saving Goals (feature mới hoàn chỉnh)
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Tạo model `SavingGoalModel` + datasource CRUD (`GET/POST/PUT/DELETE /saving-goals`) | `saving_goal_datasource.dart` (mới) |
| 2 | Tạo BLoC với events: `FetchSavingGoals`, `AddSavingGoal`, `UpdateSavingGoal`, `DeleteSavingGoal` | `saving_goal_bloc.dart` (mới) |
| 3 | Tạo trang `SavingGoalPage`: danh sách mục tiêu + progress bar + form thêm/sửa/xóa | `saving_goal_page.dart` (mới) |
| 4 | Đăng ký `SavingGoalBloc` trong `MultiBlocProvider` | `main.dart` |
| 5 | Thêm route `/saving-goals` | `main.dart` |
| 6 | Thêm link vào `ProfilePage` | `profile_page.dart` |

#### 3.8 Notifications (feature mới hoàn chỉnh)
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Tạo model `NotificationModel` + datasource (`GET /notifications`, `PUT /notifications/{id}/read`) | `notification_datasource.dart` (mới) |
| 2 | Tạo BLoC với events: `FetchNotifications`, `MarkNotificationAsRead` | `notification_bloc.dart` (mới) |
| 3 | Tạo trang `NotificationPage`: danh sách thông báo, icon theo loại, tap → markAsRead | `notification_page.dart` (mới) |
| 4 | Kết nối bell icon trên dashboard header → `/notifications` | `dashboard_page.dart` |
| 5 | Đăng ký `NotificationBloc` trong `MultiBlocProvider` | `main.dart` |
| 6 | Thêm route `/notifications` | `main.dart` |

#### 3.9 Dashboard AI Coaching Card
| # | Việc đã làm | File |
|---|-------------|------|
| 1 | Thay card hardcode bằng `BlocBuilder<AICoachingBloc>` đọc real data | `dashboard_page.dart` |
| 2 | Thêm trigger `LoadAICoachingEvent()` trong `initState` của Dashboard | `dashboard_page.dart` |
| 3 | Tap vào card → chuyển sang tab AI Coach (index 3) | `dashboard_page.dart` |

---

## 📋 DANH SÁCH FILE ĐÃ THAY ĐỔI

### Backend (Laravel)
```
Backend/app/Http/Controllers/Api/AuthController.php          ← thêm updateSettings
Backend/app/Http/Controllers/Api/TransactionController.php   ← thêm getSummary, sửa store/index/destroy
Backend/app/Http/Controllers/Api/GamificationController.php  ← thêm joinChallenge
Backend/app/Http/Controllers/Api/SavingGoalController.php    ← sửa field names
Backend/app/Http/Controllers/Api/CategoryController.php      ← sửa color→icon_color
Backend/app/Models/Transaction.php                           ← thêm user_id vào fillable + relationship
Backend/app/Services/TransactionService.php                  ← sửa threshold bug
Backend/database/migrations/2026_06_06_000001_add_user_id_to_transactions_table.php  ← mới
Backend/database/seeders/DatabaseSeeder.php                  ← sửa category type + transactions

# Ưu tiên 4
Backend/app/Providers/AppServiceProvider.php                 ← thêm JsonResource::withoutWrapping()
Backend/app/Http/Requests/RegisterRequest.php                ← MỚI
Backend/app/Http/Requests/LoginRequest.php                   ← MỚI
Backend/app/Http/Requests/UpdateSettingsRequest.php          ← MỚI
Backend/app/Http/Requests/StoreTransactionRequest.php        ← MỚI
Backend/app/Http/Requests/UpdateTransactionRequest.php       ← MỚI
Backend/app/Http/Requests/StoreWalletRequest.php             ← MỚI
Backend/app/Http/Requests/UpdateWalletRequest.php            ← MỚI
Backend/app/Http/Requests/StoreBudgetRequest.php             ← MỚI (xử lý amount/amount_limit)
Backend/app/Http/Requests/UpdateBudgetRequest.php            ← MỚI (xử lý amount/amount_limit)
Backend/app/Http/Requests/StoreSavingGoalRequest.php         ← MỚI
Backend/app/Http/Requests/UpdateSavingGoalRequest.php        ← MỚI
Backend/app/Http/Requests/StoreCategoryRequest.php           ← MỚI
Backend/app/Http/Requests/UpdateCategoryRequest.php          ← MỚI
Backend/app/Http/Resources/UserResource.php                  ← MỚI
Backend/app/Http/Resources/WalletResource.php                ← MỚI
Backend/app/Http/Resources/TransactionResource.php           ← MỚI
Backend/app/Http/Resources/BudgetResource.php                ← MỚI
Backend/app/Http/Resources/SavingGoalResource.php            ← MỚI
Backend/app/Http/Resources/CategoryResource.php              ← MỚI (ánh xạ icon_color→color)
Backend/app/Http/Controllers/Api/AuthController.php          ← dùng Form Requests + UserResource
Backend/app/Http/Controllers/Api/TransactionController.php   ← dùng Form Requests + TransactionResource
Backend/app/Http/Controllers/Api/WalletController.php        ← dùng Form Requests + WalletResource
Backend/app/Http/Controllers/Api/BudgetController.php        ← dùng Form Requests + BudgetResource
Backend/app/Http/Controllers/Api/SavingGoalController.php    ← dùng Form Requests + SavingGoalResource
Backend/app/Http/Controllers/Api/CategoryController.php      ← dùng Form Requests + CategoryResource
```

### Frontend (Flutter)
```
lib/core/constants/app_constants.dart                        ← thêm constants còn thiếu

lib/feature/auth/data/datasource/auth_datasource.dart        ← thêm logout()
lib/feature/auth/domain/repository/auth_repository.dart      ← thêm abstract logout()
lib/feature/auth/data/repository_impl/auth_repository_impl.dart  ← implement logout()
lib/feature/auth/domain/usecase/auth_usecase.dart            ← thêm executeLogout()
lib/feature/auth/presentation/bloc/auth_event.dart           ← thêm LogoutSubmitted
lib/feature/auth/presentation/bloc/auth_state.dart           ← thêm AuthLoggedOut
lib/feature/auth/presentation/bloc/auth_bloc.dart            ← thêm logout handler
lib/feature/auth/presentation/pages/login_page.dart          ← lưu user info vào prefs
lib/feature/auth/presentation/pages/register_page.dart       ← fix bug + lưu prefs + navigate
lib/feature/auth/presentation/pages/profile_page.dart        ← MỚI

lib/feature/transaction/presentation/bloc/transaction_bloc.dart  ← fix delete bug
lib/feature/transaction/presentation/widgets/edit_transaction_bottom_sheet.dart  ← MỚI
lib/feature/transaction/presentation/pages/dashboard_page.dart   ← nhiều thay đổi

lib/feature/aicoaching/data/datasource/ai_datasource.dart    ← thêm getTasks/completeTask/getChallenges/joinChallenge
lib/feature/aicoaching/data/models/aicoaching_model.dart     ← thêm AITaskModel, ChallengeModel
lib/feature/aicoaching/presentation/bloc/aicoaching_event.dart  ← thêm events
lib/feature/aicoaching/presentation/bloc/aicoaching_state.dart  ← thêm states
lib/feature/aicoaching/presentation/bloc/aicoaching_bloc.dart   ← thêm handlers + dependency AIDatasource
lib/feature/aicoaching/presentation/pages/aicoaching_page.dart  ← kết nối real AI Tasks + Challenges

lib/feature/saving_goal/saving_goal_datasource.dart          ← MỚI
lib/feature/saving_goal/saving_goal_bloc.dart                ← MỚI
lib/feature/saving_goal/saving_goal_page.dart                ← MỚI

lib/feature/notification/notification_datasource.dart        ← MỚI
lib/feature/notification/notification_bloc.dart              ← MỚI
lib/feature/notification/notification_page.dart              ← MỚI

lib/main.dart                                                ← đăng ký BLoCs mới, thêm routes

# Ưu tiên 4
lib/main.dart                                                ← DevicePreview enabled: !kReleaseMode
lib/feature/transaction/data/datasource/transaction_datasource.dart  ← xóa print debug
lib/feature/budget/presentation/widgets/add_budget_bottom_sheet.dart ← xóa comment print
```

---

## ⏳ CÒN CHƯA LÀM / CẦN QUYẾT ĐỊNH

### Ưu tiên 4 — Chuẩn hoá kiến trúc

| # | Việc cần làm | Trạng thái | Ghi chú |
|---|--------------|------------|---------|
| 1 | Tắt `DevicePreview` trong production | ✅ Xong | `enabled: !kReleaseMode` trong `main.dart` |
| 2 | Xóa toàn bộ `print()` debug | ✅ Xong | `transaction_datasource.dart`, `add_budget_bottom_sheet.dart` |
| 3 | Tạo Form Requests cho backend | ✅ Xong | 13 Form Request classes, 6 controllers cập nhật |
| 4 | Tạo API Resources chuẩn hoá response | ✅ Xong | 6 Resource classes, `AppServiceProvider` cập nhật |
| 5 | Refactor `WalletBloc` và `BudgetBloc` gọi Dio trực tiếp → qua datasource | ⏳ Chưa làm | `wallet_bloc.dart`, `budget_bloc.dart` |
| 6 | Refactor `ReportBloc` tương tự | ⏳ Chưa làm | `report_bloc.dart` |
| 7 | Thêm Policy để kiểm soát quyền | ⏳ Chưa làm | Backend |

### Ưu tiên 5 — Test (chưa làm)

| # | Việc cần làm |
|---|--------------|
| 1 | Laravel API tests: auth, wallet, transaction, budget, report |
| 2 | Flutter BLoC tests: AuthBloc, TransactionBloc, BudgetBloc, WalletBloc |
| 3 | Widget tests: LoginPage, DashboardPage (smoke test) |

### Tính năng còn thiếu / cần quyết định

| # | Mô tả | Trạng thái |
|---|-------|-----------|
| 1 | **Settings page** | ✅ Xong — `settings_page.dart` + `GET/PUT /user/settings` |
| 2 | **Badges (Huy hiệu)** | ✅ Xong — card badges trong `aicoaching_page.dart` |
| 3 | **Transaction toàn bộ** | ✅ Xong — `transaction_list_page.dart` + filter Thu/Chi/Tất cả |
| 4 | **Gemini OCR API key** | ✅ Xong — `AppSecrets.geminiApiKey` đọc từ `--dart-define`, `.vscode/launch.json` gitignored |
| 5 | **AI prompt Xpander hardcode** | ✅ Xong — prompt dùng saving goals thật từ DB |
| 6 | **AIController + ReportController query cũ** | ✅ Xong — query theo `user_id` trực tiếp |
| 7 | **Category type trong seeder cũ** nếu DB đã có dữ liệu với `'Chi phí'/'Thu nhập'` → cần chạy `migrate:fresh --seed` hoặc migration data | Cần chạy lại DB |
| 8 | **AI Coaching card trên Dashboard** nếu API Gemini lỗi sẽ hiện text lỗi thô | Chưa sửa (chờ key) |
| 9 | **`TransactionController@store`** có logic duplicate với `TransactionService@createTransaction` | Đề xuất refactor (chưa làm) |
| 10 | **Profile edit** (sửa tên/email/avatar) | Chưa làm |
| 11 | **AI Tasks** từ DB thật + completeTask cộng XP | Chưa làm |

---

## 🔧 LỆNH CẦN CHẠY SAU KHI UPDATE

```bash
# Backend — chạy migration mới (thêm user_id vào transactions)
cd Backend
php artisan migrate

# Hoặc nếu muốn reset toàn bộ DB với seed data đã fix
php artisan migrate:fresh --seed

# Ưu tiên 4 — không cần migrate thêm, Resources/Requests tự load qua composer autoload
# Nếu class không nhận, chạy lại:
php artisan optimize:clear

# Frontend — không cần thêm package, chỉ cần chạy lại
cd Frontend
flutter run
```

---

## 🗂️ CẤU TRÚC FEATURE MỚI ĐÃ TẠO

```
Frontend/lib/feature/
├── saving_goal/
│   ├── saving_goal_datasource.dart   (SavingGoalModel + SavingGoalDatasource)
│   ├── saving_goal_bloc.dart         (Events + States + Bloc)
│   └── saving_goal_page.dart         (UI: list + add/edit/delete form)
│
├── notification/
│   ├── notification_datasource.dart  (NotificationModel + NotificationDatasource)
│   ├── notification_bloc.dart        (Events + States + Bloc)
│   └── notification_page.dart        (UI: list + markAsRead)
│
└── auth/
    └── presentation/pages/
        └── profile_page.dart         (UI: avatar + tên/email + menu + logout)
```
