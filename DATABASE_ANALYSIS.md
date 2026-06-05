# DATABASE ANALYSIS

## 1. Nguồn phân tích

Schema được suy luận từ:

- `Backend/database/migrations/*.php`.
- `Backend/app/Models/*.php`.
- `Backend/database/seeders/DatabaseSeeder.php`.
- `Backend/database/seeders/MasterSeeder.php`.
- Các controller/service có thao tác đọc/ghi database.

Database phục vụ domain "Financial AI Coaching": user, ví, danh mục, giao dịch, ngân sách, mục tiêu tiết kiệm, AI review/task, thông báo, huy hiệu, thử thách.

## 2. Danh sách bảng

Các bảng migration hiện có:

- `users`.
- `wallets`.
- `categories`.
- `transactions`.
- `budgets`.
- `saving_goals`.
- `ai_reviews`.
- `ai_tasks`.
- `notifications`.
- `user_settings`.
- `badges`.
- `user_badges`.
- `challenges`.
- `user_challenges`.
- `personal_access_tokens`.

## 3. Schema từng bảng

### `users`

Migration: `Backend/database/migrations/2026_04_09_181401_create_users_table.php`.

Columns:

- `id`: primary key.
- `username`: string unique.
- `password`: string.
- `email`: string unique.
- `full_name`: string.
- `avatar`: string nullable.
- `total_points`: integer default `0`.
- `status`: string default `Hoạt động`.
- `join_date`: timestamp default current timestamp.
- `remember_token`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/User.php`.

Fillable:

- `username`, `password`, `email`, `full_name`, `avatar`, `total_points`, `status`, `join_date`.

Relations:

- `settings()`: hasOne `UserSetting`.
- `wallets()`: hasMany `Wallet`.
- `categories()`: hasMany `Category`.
- `budgets()`: hasMany `Budget`.
- `savingGoals()`: hasMany `SavingGoal`.
- `aiReviews()`: hasMany `AI_Review`.
- `notifications()`: hasMany `Notification`.
- `badges()`: belongsToMany `Badge` via `user_badges`, pivot `earned_at`.
- `challenges()`: belongsToMany `Challenge` via `user_challenges`, pivot `status`, `progress`.

### `wallets`

Migration: `Backend/database/migrations/2026_04_09_181409_create_wallets_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `name`: string.
- `type`: string.
- `initial_balance`: decimal(15,2), default `0`.
- `current_balance`: decimal(15,2), default `0`.
- `currency`: string default `VND`.
- `note`: text nullable.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/Wallet.php`.

Fillable:

- `user_id`, `name`, `type`, `initial_balance`, `current_balance`, `currency`, `note`.

Relations:

- belongsTo `User`.
- hasMany `Transaction`.

Business usage:

- `WalletController` CRUD theo user.
- `TransactionController@store` cập nhật `current_balance`.
- `TransactionService` hoàn tác/cập nhật balance khi update/delete.

### `categories`

Migration: `Backend/database/migrations/2026_04_09_181415_create_categories_table.php`.

Columns:

- `id`: primary key.
- `user_id`: nullable foreign key to `users.id`, cascade delete.
- `name`: string.
- `type`: string.
- `icon_color`: string nullable.
- `is_default`: boolean default `false`.
- `created_at`, `updated_at`.
- `icon`: string nullable.

Model: `Backend/app/Models/Category.php`.

Fillable:

- `user_id`, `name`, `type`, `icon_color`, `is_default`, `icon`.

Relations:

- belongsTo `User`.
- hasMany `Transaction`.

Business usage:

- Category có thể là default/global nếu `user_id` null.
- `ReportController` eager-load `category:id,name,icon_color`.
- `Budget` bắt buộc có `category_id`.
- `Transaction` bắt buộc có `category_id`.

Schema/API mismatch:

- `CategoryController` validate request field `color`, nhưng bảng là `icon_color`.
- `Frontend CategoryModel` đọc `color`, nhưng report model đọc `icon_color`.
- Seeder dùng type tiếng Việt như `Chi phí`, `Thu nhập`, còn controller validate create/update là `income`, `expense`.

### `transactions`

Migration:

- `Backend/database/migrations/2026_04_09_181421_create_transactions_table.php`.
- `Backend/database/migrations/2026_06_03_172200_add_type_to_transactions_table.php`.

Columns:

- `id`: primary key.
- `wallet_id`: foreign key to `wallets.id`, cascade delete.
- `category_id`: foreign key to `categories.id`, cascade delete.
- `type`: string(10), default `Chi`, added after `category_id`.
- `amount`: decimal(15,2).
- `date`: datetime.
- `note`: text nullable.
- `image_url`: string nullable.
- `status`: string default `Hoàn thành`.
- `source`: string nullable.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/Transaction.php`.

Fillable:

- `wallet_id`, `category_id`, `type`, `amount`, `date`, `note`, `image_url`, `status`, `source`.

Relations:

- belongsTo `Wallet`.
- belongsTo `Category`.

Business usage:

- Đây là bảng trung tâm để tính dashboard, report, AI review.
- Thu/chi được phân biệt bằng `type`: `Thu` hoặc `Chi` trong backend validation.
- Khi thêm giao dịch:
  - `Thu`: tăng `wallet.current_balance`.
  - `Chi`: giảm `wallet.current_balance`, cập nhật `budget.spent_amount` nếu có budget phù hợp.
- Khi update/delete: `TransactionService` hoàn tác số dư ví và tính lại budget.

Schema/API mismatch:

- `TransactionController@store` thêm `$transactionData['user_id']`, nhưng bảng không có cột `user_id` và model không fillable `user_id`.
- Ownership giao dịch được suy ra qua `wallet_id -> wallets.user_id`, không qua `transactions.user_id`.
- `DatabaseSeeder` thêm transactions không set `type`, nên default toàn bộ là `Chi`, kể cả record "Lương làm thêm".

### `budgets`

Migration: `Backend/database/migrations/2026_04_09_182108_create_budgets_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `category_id`: foreign key to `categories.id`, cascade delete.
- `amount_limit`: decimal(15,2).
- `spent_amount`: decimal(15,2), default `0`.
- `start_date`: date.
- `end_date`: date.
- `alert_threshold`: integer default `80`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/Budget.php`.

Fillable:

- `user_id`, `category_id`, `amount_limit`, `spent_amount`, `start_date`, `end_date`, `alert_threshold`.

Relations:

- belongsTo `User`.
- belongsTo `Category`.

Business usage:

- `BudgetController` CRUD theo user.
- `TransactionController@store` cộng `spent_amount` nếu giao dịch chi nằm trong khoảng `start_date` đến `end_date`.
- `TransactionService@handleBudgetLogic` tính lại tổng chi tháng hiện tại cho category và tạo notification nếu vượt threshold.

Risk/mismatch:

- `alert_threshold` lưu integer `80`, nhưng `TransactionService` dùng `$limit * $threshold`; nếu threshold là `80`, điều kiện cảnh báo thành 8000% hạn mức. Logic đúng thường là `$limit * ($threshold / 100)`.
- `BudgetController` default threshold là `80`, phù hợp kiểu phần trăm, không phù hợp kiểu tỷ lệ `0.8`.

### `saving_goals`

Migration: `Backend/database/migrations/2026_04_09_182141_create_saving_goals_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `goal_name`: string.
- `target_amount`: decimal(15,2).
- `current_amount`: decimal(15,2), default `0`.
- `deadline`: date nullable.
- `status`: string default `Đang thực hiện`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/SavingGoal.php`.

Fillable:

- `user_id`, `goal_name`, `target_amount`, `current_amount`, `deadline`, `status`.

Relations:

- belongsTo `User`.

Schema/API mismatch:

- `SavingGoalController` validate `name`, `target_date`, `color`.
- Model/migration dùng `goal_name`, `deadline`, không có `color`.
- Vì vậy `store()` có nguy cơ không lưu được đúng field hoặc trả lỗi mass assignment/schema nếu request theo controller hiện tại.

### `ai_reviews`

Migration: `Backend/database/migrations/2026_04_09_182159_create_ai_reviews_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `content`: text.
- `review_type`: string.
- `financial_health_score`: integer default `0`.
- `forecast_data`: json nullable.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/AI_Review.php`.

Fillable:

- `user_id`, `content`, `review_type`, `financial_health_score`, `forecast_data`.

Casts:

- `forecast_data` cast to array.

Relations:

- belongsTo `User`.
- hasMany `AI_Task` via `review_id`.

Business usage:

- Seeder có dữ liệu AI review mẫu.
- `AIController@getReviews` hiện không đọc bảng `ai_reviews`; nó gọi Gemini realtime và trả response khác schema (`review`, `financial_score`).

### `ai_tasks`

Migration: `Backend/database/migrations/2026_04_09_182207_create_ai_tasks_table.php`.

Columns:

- `id`: primary key.
- `review_id`: foreign key to `ai_reviews.id`, cascade delete.
- `task_name`: string.
- `description`: text nullable.
- `points_reward`: integer default `0`.
- `deadline`: datetime.
- `status`: string default `Chưa làm`.
- `user_response`: text nullable.
- `completed_at`: timestamp nullable.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/AI_Task.php`.

Fillable:

- `review_id`, `task_name`, `description`, `points_reward`, `deadline`, `status`, `user_response`, `completed_at`.

Relations:

- belongsTo `AI_Review`.

Business usage:

- Seeder có task mẫu.
- `AIController@getTasks` trả task hard-code, không đọc bảng này.
- `AIController@completeTask` không cập nhật bảng này.

### `notifications`

Migration: `Backend/database/migrations/2026_04_09_182212_create_notifications_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `title`: string.
- `message`: text.
- `type`: string.
- `is_read`: boolean default `false`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/Notification.php`.

Fillable:

- `user_id`, `title`, `message`, `type`, `is_read`.

Relations:

- belongsTo `User`.

Business usage:

- `NotificationController@index`: list notifications.
- `NotificationController@markAsRead`: mark read.
- `TransactionService`: tạo budget alert.
- `GamificationService`: tạo notification nhận badge.

### `user_settings`

Migration: `Backend/database/migrations/2026_04_09_182217_create_user_settings_table.php`.

Columns:

- `user_id`: primary key, foreign key to `users.id`, cascade delete.
- `language`: string default `vi`.
- `theme`: string default `Light`.
- `enable_ai`: boolean default `true`.
- `daily_reminder_time`: time nullable.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/UserSetting.php`.

Fillable:

- `user_id`, `language`, `theme`, `enable_ai`, `daily_reminder_time`.

Relations:

- belongsTo `User`.

Business usage:

- User model hasOne settings.
- Route `PUT /api/user/settings` tồn tại nhưng thiếu controller method.

### `badges`

Migration: `Backend/database/migrations/2026_04_09_182222_create_badges_table.php`.

Columns:

- `id`: primary key.
- `name`: string.
- `description`: text nullable.
- `icon_url`: string nullable.
- `xp_reward`: integer default `0`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/Badge.php`.

Fillable:

- `name`, `description`, `icon_url`, `xp_reward`.

Relations:

- belongsToMany `User` via `user_badges`.

Business usage:

- `GamificationController@getMyBadges`.
- `GamificationService@checkAndAwardBadges`.

### `user_badges`

Migration: `Backend/database/migrations/2026_04_09_182226_create_user_badges_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `badge_id`: foreign key to `badges.id`, cascade delete.
- `earned_at`: timestamp current.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/User_Badge.php`.

Fillable:

- `user_id`, `badge_id`, `earned_at`.

Relation role:

- Pivot table many-to-many giữa users và badges.

### `challenges`

Migration: `Backend/database/migrations/2026_04_09_182231_create_challenges_table.php`.

Columns:

- `id`: primary key.
- `name`: string.
- `description`: text nullable.
- `start_date`: date.
- `end_date`: date.
- `type`: string default `Hệ thống`.
- `reward_points`: integer default `0`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/Challenge.php`.

Fillable:

- `name`, `description`, `start_date`, `end_date`, `type`, `reward_points`.

Relations:

- belongsToMany `User` via `user_challenges`.

Business usage:

- `GamificationController@index` lấy active challenges.
- `POST /challenges/{id}/join` route tồn tại nhưng thiếu implementation.

### `user_challenges`

Migration: `Backend/database/migrations/2026_04_09_182236_create_user_challenges_table.php`.

Columns:

- `id`: primary key.
- `user_id`: foreign key to `users.id`, cascade delete.
- `challenge_id`: foreign key to `challenges.id`, cascade delete.
- `status`: string default `Đang tham gia`.
- `progress`: integer default `0`.
- `created_at`, `updated_at`.

Model: `Backend/app/Models/User_Challenge.php`.

Fillable:

- `user_id`, `challenge_id`, `status`, `progress`.

Relation role:

- Pivot table many-to-many giữa users và challenges.

### `personal_access_tokens`

Migration: `Backend/database/migrations/2026_04_09_193231_create_personal_access_tokens_table.php`.

Columns:

- `id`: primary key.
- `tokenable_type`, `tokenable_id`: polymorphic owner.
- `name`: text.
- `token`: string(64) unique.
- `abilities`: text nullable.
- `last_used_at`: timestamp nullable.
- `expires_at`: timestamp nullable indexed.
- `created_at`, `updated_at`.

Business usage:

- Laravel Sanctum lưu access tokens cho login/register/logout.

## 4. Quan hệ database

Quan hệ chính:

- `users 1-1 user_settings`.
- `users 1-n wallets`.
- `users 1-n categories`.
- `users 1-n budgets`.
- `users 1-n saving_goals`.
- `users 1-n ai_reviews`.
- `users 1-n notifications`.
- `wallets 1-n transactions`.
- `categories 1-n transactions`.
- `categories 1-n budgets`.
- `ai_reviews 1-n ai_tasks`.
- `users n-n badges` qua `user_badges`.
- `users n-n challenges` qua `user_challenges`.
- `users 1-n personal_access_tokens` qua Sanctum polymorphic `tokenable`.

Quan hệ nghiệp vụ suy luận:

- Transaction thuộc user gián tiếp qua wallet:
  - `transactions.wallet_id -> wallets.id -> wallets.user_id`.
- Spending report lấy user bằng quan hệ ngược:
  - `Transaction::whereHas('wallet', where user_id = current user)`.
- Budget gắn user và category độc lập:
  - Khi giao dịch `Chi`, hệ thống tìm budget cùng `user_id`, `category_id`, và `date` nằm trong kỳ ngân sách.
- Notification là kết quả của rule nghiệp vụ:
  - budget alert.
  - badge awarded.

## 5. Luồng cập nhật dữ liệu quan trọng

### Đăng ký user

1. `AuthController@register` validate request.
2. Insert `users`.
3. Hash password bằng `Hash::make`.
4. Tạo Sanctum token trong `personal_access_tokens`.
5. Trả token cho Flutter.

Không thấy tạo tự động `user_settings` sau register. Seeder có tạo settings, nhưng runtime register thì chưa.

### Tạo ví

1. `WalletController@store` validate.
2. Insert `wallets` với `user_id` từ token.
3. Set `current_balance = initial_balance`.

### Tạo giao dịch

1. `TransactionController@store` validate.
2. Kiểm tra wallet có thuộc user hiện tại.
3. `DB::beginTransaction`.
4. Insert `transactions`.
5. Cập nhật `wallet.current_balance`.
6. Nếu `type = Chi`, cộng `budget.spent_amount` cho budget cùng category và kỳ thời gian.
7. Commit.

### Update transaction

1. `TransactionController@update` validate.
2. `TransactionService@updateTransaction` tìm transaction.
3. Hoàn tác balance cũ.
4. Update transaction.
5. Áp dụng balance mới.
6. Nếu type là chi, recalc budget theo tháng hiện tại.

### Delete transaction

1. `TransactionService@deleteTransaction` tìm transaction.
2. Hoàn tác balance.
3. Xóa transaction.
4. Recalc budget category tương ứng.

### Budget alert

1. `TransactionService@handleBudgetLogic` tính total spent tháng hiện tại.
2. Update `budgets.spent_amount`.
3. Nếu total spent vượt threshold thì kiểm tra notification đã tồn tại trong ngày.
4. Nếu chưa, insert `notifications`.

### Gamification

1. `GamificationService@addPoints` tăng `users.total_points`.
2. `checkAndAwardBadges` tìm badges user chưa có.
3. Nếu đủ điều kiện, attach vào `user_badges`.
4. Insert notification chúc mừng.

Ghi chú: `TransactionController@store` hiện tự xử lý tạo transaction nên không gọi `TransactionService@createTransaction`; do đó gamification add points trong `TransactionService@createTransaction` có thể không chạy với luồng tạo giao dịch hiện tại.

## 6. Seed data

`Backend/database/seeders/DatabaseSeeder.php` tạo:

- User `ngochiep`.
- User settings.
- Categories: Ăn uống, Tiền trọ, Lương làm thêm, Di chuyển.
- Wallets: Tiền mặt, Vietcombank.
- Transactions mẫu.
- Budget cho Ăn uống.
- Saving goal "Mua Laptop Gaming".
- AI review và AI task.
- Notification.
- Badge.
- User badge.
- Challenge.
- User challenge.

`Backend/database/seeders/MasterSeeder.php` tạo:

- Categories mẫu: Ăn uống, Di chuyển, Mua sắm, Lương.
- Badges mẫu: Người tiết kiệm, Thần đèn ghi chép.
- Challenge mẫu: 7 Ngày Tiết Kiệm.

Rủi ro seed:

- `DatabaseSeeder` transactions không có `type`; sau migration add type, default là `Chi`.
- `MasterSeeder` category type là `expense/income`, còn `DatabaseSeeder` dùng `Chi phí/Thu nhập`.
- Nếu chạy cả hai seeder, category semantics có thể không đồng nhất.

## 7. Chỉ mục và ràng buộc

Đã có:

- Unique `users.username`.
- Unique `users.email`.
- Unique `personal_access_tokens.token`.
- Index `personal_access_tokens.expires_at`.
- Foreign keys cascade delete cho hầu hết quan hệ con.

Chưa thấy:

- Composite unique tránh user join cùng challenge nhiều lần.
- Composite unique tránh user nhận cùng badge nhiều lần.
- Index rõ ràng cho query thường dùng:
  - `wallets.user_id`.
  - `transactions.wallet_id`, `transactions.category_id`, `transactions.date`.
  - `budgets.user_id`, `budgets.category_id`, `budgets.start_date`, `budgets.end_date`.
  - `notifications.user_id`, `notifications.created_at`.

Foreign key tự tạo index trong nhiều database, nhưng các composite index cho report/budget vẫn nên cân nhắc nếu dữ liệu lớn.

## 8. Các vấn đề schema/code cần ưu tiên kiểm tra

1. `transactions.user_id`:
   - Controller gán `user_id`, nhưng schema không có.
   - Nên chọn một hướng: bỏ gán `user_id` hoặc thêm cột `user_id` và đồng bộ model.

2. `saving_goals` field mismatch:
   - Controller: `name`, `target_date`, `color`.
   - DB/model: `goal_name`, `deadline`, `status`.
   - Cần sửa controller hoặc migration/model.

3. `categories.color` vs `icon_color`:
   - Controller/Flutter model dùng `color`.
   - DB/report dùng `icon_color`.
   - Cần thống nhất response/request.

4. Category type:
   - Backend validate `income/expense`.
   - Transaction UI dùng `Thu/Chi`.
   - Seeder dùng cả `Chi phí/Thu nhập` và `expense/income`.
   - Nên chuẩn hóa enum hoặc mapping.

5. Budget threshold:
   - DB lưu `80`.
   - Service tính như tỷ lệ trực tiếp.
   - Nên dùng phần trăm (`80`) với chia 100 hoặc lưu ratio (`0.8`).

6. AI tables chưa được controller sử dụng:
   - `ai_reviews`, `ai_tasks` hiện chủ yếu là schema/seed.
   - API AI review realtime không persist.
   - API AI tasks hard-code.

7. Missing settings/challenge/summary handlers:
   - `updateSettings`, `joinChallenge`, `getSummary` chưa tồn tại.

## 9. Database schema suy luận dạng text ERD

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

