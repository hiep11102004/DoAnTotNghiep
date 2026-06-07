# UI Redesign Plan — AI Financial Coach

> **Vai trò phân tích:** Senior Product Designer + Senior Flutter Developer  
> **Ngày tạo:** 06/06/2026  
> **Phạm vi:** Toàn bộ màn hình Flutter hiện tại  
> **Mục tiêu:** Xác định cải tiến có tác động lớn nhất trước khi bắt đầu redesign thực tế

---

## Mục lục

1. [Tổng quan điểm số UI Audit](#1-tổng-quan-điểm-số-ui-audit)
2. [Dashboard](#2-dashboard--phân-tích-chi-tiết)
3. [Wallet](#3-wallet)
4. [Budget](#4-budget)
5. [Transaction List](#5-transaction-list)
6. [Report](#6-report)
7. [AI Coaching](#7-ai-coaching)
8. [Saving Goals](#8-saving-goals)
9. [Profile](#9-profile)
10. [Settings](#10-settings)
11. [Login / Register](#11-login--register)
12. [Bảng ưu tiên redesign](#12-bảng-ưu-tiên-redesign)
13. [Component Library đề xuất](#13-component-library-đề-xuất)

---

## 1. Tổng quan điểm số UI Audit

| Màn hình | Visual Hierarchy | Readability | Info Density | UX Flow | Consistency | Modern Design | Điểm tổng |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Dashboard** | 5/10 | 6/10 | 4/10 | 5/10 | 5/10 | 5/10 | **5.0** |
| **Wallet** | 7/10 | 7/10 | 7/10 | 6/10 | 8/10 | 7/10 | **7.0** |
| **Budget** | 7/10 | 7/10 | 7/10 | 6/10 | 8/10 | 7/10 | **7.0** |
| **Transaction List** | 7/10 | 8/10 | 7/10 | 7/10 | 7/10 | 7/10 | **7.2** |
| **Report** | 7/10 | 7/10 | 6/10 | 5/10 | 7/10 | 6/10 | **6.3** |
| **AI Coaching** | 7/10 | 7/10 | 7/10 | 7/10 | 8/10 | 7/10 | **7.2** |
| **Saving Goals** | 7/10 | 8/10 | 7/10 | 7/10 | 8/10 | 7/10 | **7.3** |
| **Profile** | 8/10 | 8/10 | 8/10 | 8/10 | 8/10 | 7/10 | **7.8** |
| **Settings** | 8/10 | 8/10 | 8/10 | 8/10 | 9/10 | 7/10 | **8.0** |
| **Login/Register** | 7/10 | 8/10 | 8/10 | 7/10 | 8/10 | 7/10 | **7.5** |

> Dashboard có điểm **thấp nhất** và là nơi người dùng tương tác nhiều nhất — đây là ưu tiên số 1.

---

## 2. Dashboard — Phân tích chi tiết

### 2.1 Hiện trạng (layout từ trên xuống)

```
┌──────────────────────────────────┐
│  [Tổng số dư] [dark gradient]    │  ← ~200px
│  Tiền vào | Tiền ra              │
│  ─── Danh sách ví (65px) ────    │
└──────────────────────────────────┘
┌──────────────────────────────────┐
│  [AI FINN card] [dark blue]      │  ← ~90px
└──────────────────────────────────┘
┌──────────────────────────────────┐
│  Ngân sách tháng này  [+]        │
│  BudgetCard x2                   │  ← ~200px
└──────────────────────────────────┘
┌──────────────────────────────────┐
│  Giao dịch gần đây               │
│  TransactionTile x3              │  ← ~200px
│  [Xem tất cả]                    │
└──────────────────────────────────┘
```

### 2.2 Vấn đề nghiêm trọng

#### ❌ Information Overload
- Trang chủ hiển thị **4 section nặng** trong một scroll dài. Trên điện thoại 6", người dùng phải scroll 3–4 lần để xem hết nội dung.
- Quy tắc vàng của Financial App UX: **Dashboard chỉ nên trả lời 3 câu hỏi:**
  1. Tôi có bao nhiêu tiền? (Balance)
  2. Tháng này tôi tiêu như thế nào? (Trend)
  3. Tôi cần làm gì tiếp theo? (Action)

#### ❌ Dark-on-Dark collision
- Header card (`0F2027 → 2C5364`) + AI card (`1F4068 → 162447`) đặt liền nhau → **hai khối tối liền kề** không có breathing room. Gây cảm giác nặng nề, mất phân cấp thị giác.

#### ❌ Wallet carousel quá nhỏ (65px)
- Text size 10–11px, không đáp ứng ngưỡng readability tối thiểu (14px).
- Touch target của mỗi ví ~140×65px — chuẩn iOS/Material là ≥44×44pt. Technically đủ nhưng cảm giác rất chật.
- Icon `wallet.balance` gọi field không tồn tại trong `WalletEntity` (có `currentBalance`, không có `balance`) → **bug tiềm ẩn**.

#### ❌ AI Coaching Card bị trùng vai trò
- Mini AI card trên Dashboard → user tap → chuyển sang tab AI Coaching.
- Nhưng AI Coaching đã có tab riêng trên bottom nav.
- Kết quả: **hai entry point** cho cùng một tính năng, gây nhầm lẫn về vai trò của card trên Dashboard.
- Card trên Dashboard nên thể hiện **insight ngắn gọn**, không phải điểm truy cập tab.

#### ❌ Budget section không cần thiết trên Dashboard
- Budget đã có tab/page riêng.
- Hiển thị 2 BudgetCard đầy đủ trên Dashboard làm trang chủ trở nên giống một tổng hợp report, không phải "home".
- Nên thay bằng **1 progress indicator nhỏ gọn** (tổng đã tiêu / tổng hạn mức).

#### ❌ Bottom Navigation
- `_buildBottomNavItem` dùng `InkWell` thay vì `NavigationBar` của Material 3.
- Slot index 2 (`SizedBox.shrink()`) là placeholder hack cho FAB — gây lỗi lôgic nếu quản lý state.
- Không có **active indicator** rõ ràng (chỉ đổi màu text/icon, không có pill/underline).
- Tab label "Tổng quan" quá dài (10 ký tự) trên font 10px.

#### ❌ Không có header cá nhân hóa
- Không có greeting ("Xin chào, [Tên]!"), không có ngày/tháng.
- Mọi Financial App hàng đầu (Revolut, Money Lover, Misa) đều có phần này.

#### ⚠️ Thành phần đang chiếm diện tích không cần thiết
- "Ngân sách tháng này" với 2 BudgetCard đầy đủ: ~200px dư thừa
- "Danh sách ví" trong header card: có thể giảm xuống text đơn giản hoặc pill chips
- Budget section "Xem tất cả X ngân sách" button gọi `() {}` (chưa navigate)

### 2.3 Điểm mạnh nên giữ lại

- ✅ Toggle ẩn/hiện số dư (`_showBalance`)
- ✅ Smart transaction icon mapping theo keyword ghi chú
- ✅ Balance tổng = income - expense (real-time từ TransactionBloc)
- ✅ FAB ở giữa bottom nav (pattern phổ biến trong financial apps)
- ✅ Màu `income: #69F0AE`, `expense: #FF8A80` trên nền tối đọc tốt

### 2.4 Mockup Layout mới đề xuất

```
ZONE A — STICKY HEADER (không scroll)
┌──────────────────────────────────────┐
│ [Avatar] Xin chào, Hiep!   [🔔]     │  ← 56px
│          Thứ 7, 06/06/2026           │
└──────────────────────────────────────┘

ZONE B — HERO BALANCE CARD
┌──────────────────────────────────────┐
│  Tổng số dư                   [👁]   │
│                                      │
│    ₫ 12,500,000                      │  ← Số lớn, font 32sp
│                                      │
│  [↑ Thu: +5,200,000] [↓ Chi: -2,700,000]│  ← 2 pill chips
│                                      │
│  ○ Tiền mặt   ○ VCB   ○ +Thêm ví   │  ← Wallet dots compact
└──────────────────────────────────────┘

ZONE C — QUICK ACTIONS (1 row, 4 actions)
┌─────┬─────┬─────┬─────┐
│ [+] │ [📊]│ [🎯]│ [🤖]│
│ Thêm│ B/Cáo│Mục tiêu│AI │
└─────┴─────┴─────┴─────┘

ZONE D — SCROLLABLE CONTENT
┌──────────────────────────────────────┐
│ 💡 FINN nói:                          │  ← Compact AI insight (1 dòng)
│ "Chi tiêu tháng này giảm 15%..."     │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ Ngân sách tháng   ▓▓▓▓▓░░ 72%       │  ← 1 progress bar compact
│ 3,240,000 / 4,500,000                │     bỏ BudgetCard đầy đủ
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ Giao dịch gần đây        [Xem tất cả]│
│ ─── Hôm nay ──────────────────────  │
│ [icon] Cà phê           -35,000      │
│ [icon] Lương            +8,000,000   │
│ ─── Hôm qua ──────────────────────  │
│ [icon] Shopee           -250,000     │
└──────────────────────────────────────┘
```

**Thay đổi chính:**
- Tách header thành sticky bar (không cuộn) + hero card (cuộn)
- Quick actions thay thế budget section
- AI insight rút gọn thành 1–2 dòng, không phải card riêng
- Budget indicator compact thay vì 2 BudgetCard đầy đủ
- Transaction list với date grouping

---

## 3. Wallet

### Điểm mạnh ✅
- Total balance summary card với gradient xanh lá
- Wallet card với icon và format tiền chuẩn
- FAB để thêm ví
- Empty state và error state
- `initState` fetch data

### Điểm yếu ❌
- Icon chọn theo `wallet.id % 4` — vô nghĩa, không liên quan đến loại ví
- Không có màu sắc cá nhân hóa cho từng ví (Money Lover cho phép chọn màu ví)
- Không có edit/delete wallet
- Không có wallet type (Tiền mặt, Ngân hàng, Thẻ tín dụng)
- Card thiếu thông tin: không hiện loại ví, không hiện số giao dịch

### Thành phần nên redesign
- **Wallet card**: Thêm màu accent tùy chỉnh, loại ví, % thay đổi so với tháng trước
- **Total card**: Thêm sparkline mini-chart (xu hướng 7 ngày)

### Mockup gợi ý (Money Lover / Revolut style)

```
REVOLUT STYLE — Wallet Card
┌──────────────────────────────────┐
│  [████ accent color ███████████]  │
│  💳 Vietcombank                   │
│     Ngân hàng · *** 4521          │
│                                  │
│  ₫ 8,200,000              ↑2.3% │
└──────────────────────────────────┘

MONEY LOVER STYLE — Wallet Card  
┌────────────────────────────────┐
│ [Colored dot] Tiền mặt  [···] │
│                                │
│     ₫ 4,300,000               │
│                                │
│ 12 giao dịch tháng này        │
└────────────────────────────────┘
```

---

## 4. Budget

### Điểm mạnh ✅
- Summary card tổng (đã thêm)
- BudgetCard với progress bar + màu động
- FAB + empty state
- Trạng thái "Còn lại / Vượt hạn mức"

### Điểm yếu ❌
- Không có **month selector** — luôn hiện tháng hiện tại, người dùng không thể xem lại tháng trước
- Category mapping hardcode (chỉ 6 category ID cố định) — sẽ lỗi khi có category khác
- Không có **spending breakdown**: không biết đã tiêu vào ngày nào trong tháng
- Không có visual so sánh với tháng trước

### Thành phần nên redesign
- **Month selector header**: `< Tháng 5 | Tháng 6 >` navigation
- **Category name**: Lấy từ BudgetEntity (tên thật từ DB) thay vì hardcode

### Mockup gợi ý (Misa Money Keeper style)

```
┌──────────────────────────────────────┐
│  < Tháng 5/2026     Tháng 6/2026 >  │  ← Month picker
│                                      │
│  Đã dùng      3,240,000 / 4,500,000 │
│  ▓▓▓▓▓▓▓▓░░░░░░░░  72%              │
│  Còn lại: 1,260,000  ✅ An toàn     │
└──────────────────────────────────────┘

[Budget Card - per category]
┌──────────────────────────────────────┐
│ 🍔 Ăn uống              ●●●●●●●○○○  │
│    Đã tiêu: 800k / 1,200k — 67%     │
│    Còn lại: 400k · Đến 30/06        │
└──────────────────────────────────────┘
```

---

## 5. Transaction List

### Điểm mạnh ✅
- Filter chips (Tất cả / Thu / Chi) với animation
- Swipe-to-delete với confirm dialog
- Tap-to-edit
- Empty state

### Điểm yếu ❌
- **Không có date grouping** — tất cả transaction xếp thẳng hàng, khó tìm
- Không có **search bar**
- Không có **sort option** (mới nhất / cũ nhất / cao nhất)
- Không có **FAB** để thêm giao dịch nhanh
- AppBar chưa dùng `AppWidgets.appBar`
- Empty state chưa dùng `AppWidgets.emptyState`

### Mockup đề xuất

```
┌──────────────────────────────────────┐
│ ← Tất cả giao dịch              🔍  │
│ [Tất cả] [Thu nhập] [Chi tiêu]      │
│ ─── Hôm nay, 06/06 ──────────────── │
│ [🍔] Cà phê          -35,000        │
│ [💰] Lương          +8,000,000      │
│ ─── Hôm qua, 05/06 ──────────────── │
│ [🛒] Shopee          -250,000       │
└──────────────────────────────────────┘
```

---

## 6. Report

### Điểm mạnh ✅
- Pie chart tương tác (touch to highlight)
- Legend với Divider + % tỷ trọng (mới thêm)
- AppBar chuẩn
- Empty/error state

### Điểm yếu ❌
- **Không có time period selector** — chỉ xem được tháng hiện tại
- **Chỉ có pie chart** — không có bar chart, line chart xu hướng
- Không có **tổng chi tiêu** hiển thị nổi bật
- Chart không có center label (donut style với tổng ở giữa)
- Không có so sánh tháng này vs tháng trước

### Thành phần nên redesign

```
REPORT PAGE — Đề xuất layout

[< Tháng 5 | Tháng 6 >]   [Chi tiêu ▼]

┌────────────────────────────────┐
│  Tổng chi tiêu tháng 6        │
│       ₫ 4,500,000              │
│    ( Donut Chart )             │
│  ↑ 12% so với tháng 5         │
└────────────────────────────────┘

[Theo danh mục]  [Theo ngày]  ← Tab toggle

THEO DANH MỤC:
Legend list với bar mini-chart per item

THEO NGÀY:
Bar chart theo ngày trong tháng
```

---

## 7. AI Coaching

### Điểm mạnh ✅
- `_buildSectionTitle()` helper nhất quán
- AppColors chuẩn
- Task completion interactive
- Badges grid với Wrap
- Challenge card với join button

### Điểm yếu ❌
- **Không có XP / Level display** — gamification thiếu context quan trọng nhất
- AI text hiện raw paragraph dài, khó đọc nhanh
- Không có **progress ring** quanh avatar hoặc level bar
- Challenge card chỉ có "Tham gia" — không biết user đã join chưa, tiến độ bao nhiêu

### Thành phần nên thêm

```
HEADER SECTION (mới)
┌──────────────────────────────────────┐
│  [Avatar] Hiep                       │
│  Level 5 · FINN Member               │
│  [▓▓▓▓▓▓▓░░░] 650 / 1000 XP       │
│  250 XP để lên Level 6              │
└──────────────────────────────────────┘
```

---

## 8. Saving Goals

### Điểm mạnh ✅
- Dynamic progress colors (primary→warning→income)
- Card layout gọn gàng với icon
- Form bottom sheet với AppWidgets.inputDecoration
- Drag handle trên bottom sheet
- Empty state chuẩn

### Điểm yếu ❌
- Không có **contribution history** (đã nạp vào mục tiêu bao nhiêu lần)
- Không có **quick add** (nút +X để thêm tiền nhanh vào mục tiêu)
- Không có **deadline urgency indicator** (còn X ngày)
- Status "Đang thực hiện" / "Hoàn thành" hiện theo text từ DB, không map sang friendly label

### Mockup cải thiện

```
SAVING GOAL CARD — Enhanced
┌──────────────────────────────────────┐
│ 🎯 Mua iPhone 16 Pro          [···] │
│                                      │
│ ▓▓▓▓▓▓░░░░░░  58% hoàn thành        │
│                                      │
│ ₫5,800,000      /    ₫10,000,000    │
│ Đã tiết kiệm         Mục tiêu        │
│                                      │
│ [+Nạp tiền]  ● 45 ngày còn lại      │
└──────────────────────────────────────┘
```

---

## 9. Profile

### Điểm mạnh ✅
- Avatar với drop shadow
- Tách logout card riêng với red-tinted border
- Menu grouping trong card
- `AppWidgets.cardDecoration()`

### Điểm yếu (nhỏ) ⚠️
- Avatar luôn là initial letter — thiếu option upload ảnh
- Không có stats nhanh (tổng giao dịch, kỳ sử dụng)
- Không có app version/info section

### Thành phần nên thêm (nhỏ)

```
PROFILE HEADER — Cải thiện
┌──────────────────────────────────────┐
│                                      │
│         [Avatar  + camera icon]      │
│         Ngoc Hiep                    │
│         ngochip@gmail.com            │
│                                      │
│ ┌──────┬──────┬──────┐              │
│ │  128 │  6   │  3   │              │
│ │ GD   │Ví    │ Mục tiêu│          │
│ └──────┴──────┴──────┘              │
└──────────────────────────────────────┘
```

---

## 10. Settings

### Điểm mạnh ✅
- Section grouping chuẩn
- AppColors và AppTextStyles nhất quán
- Save button loading state trên AppBar
- SnackBar floating

### Điểm yếu (rất nhỏ) ⚠️
- Khi `_isSaving = true`, spinner hiện trong AppBar button rất nhỏ và không dễ nhận thấy
- Không có "Unsaved changes" indicator khi người dùng thay đổi settings mà chưa save

---

## 11. Login / Register

### Điểm mạnh ✅
- Màu xanh lá đồng bộ với app
- Password visibility toggle
- Logo gradient icon
- SnackBar floating

### Điểm yếu (nhỏ) ⚠️
- Loading state chỉ disable button — không có visual change mạnh (nên thêm opacity hoặc skeleton)
- Login page header chiếm nhiều không gian — trên điện thoại nhỏ (<5.5") form bị đẩy xuống nhiều

---

## 12. Bảng ưu tiên redesign

| Thứ tự | Màn hình | Vấn đề chính | Tác động | Độ khó | Sprint |
|:---:|---|---|:---:|:---:|:---:|
| 🔴 **1** | **Dashboard** | Quá dense, dark-on-dark, wallet bug, no greeting | ★★★★★ | Khó | Sprint 1 |
| 🔴 **2** | **Transaction List** | Date grouping, search bar, no FAB | ★★★★☆ | Trung bình | Sprint 1 |
| 🟡 **3** | **Report** | Time selector, donut chart, bar chart | ★★★★☆ | Trung bình | Sprint 2 |
| 🟡 **4** | **Wallet** | Icon hack, no edit/delete, no type | ★★★☆☆ | Dễ-Trung bình | Sprint 2 |
| 🟡 **5** | **Budget** | Month selector, category name từ DB | ★★★☆☆ | Dễ-Trung bình | Sprint 2 |
| 🟡 **6** | **AI Coaching** | XP/Level header, challenge state | ★★★☆☆ | Dễ | Sprint 3 |
| 🟢 **7** | **Saving Goals** | Quick add, deadline urgency | ★★☆☆☆ | Dễ | Sprint 3 |
| 🟢 **8** | **Profile** | Stats summary, avatar upload | ★★☆☆☆ | Dễ | Sprint 3 |
| 🟢 **9** | **Settings** | Save indicator rõ hơn | ★☆☆☆☆ | Rất dễ | Sprint 4 |
| 🟢 **10** | **Login/Register** | Minor spacing | ★☆☆☆☆ | Rất dễ | Sprint 4 |

### Ước lượng thời gian

| Sprint | Nội dung | Ước lượng |
|---|---|---|
| **Sprint 1** | Dashboard full redesign + Transaction List improvements | 3–4 ngày |
| **Sprint 2** | Report (chart mới) + Wallet + Budget | 3–4 ngày |
| **Sprint 3** | AI Coaching XP + Saving Goals + Profile stats | 2–3 ngày |
| **Sprint 4** | Polish: Settings, Login, micro-interactions | 1–2 ngày |

---

## 13. Component Library đề xuất

### Components nên tạo mới (tái sử dụng nhiều nơi)

| Component | Dùng ở đâu | Mô tả |
|---|---|---|
| `GreetingHeader` | Dashboard | Avatar nhỏ + greeting + ngày + notification bell |
| `BalanceHeroCard` | Dashboard, Wallet | Card balance lớn với toggle ẩn/hiện, income/expense pills |
| `QuickActionGrid` | Dashboard | 4 icon button (Thêm, Báo cáo, Mục tiêu, AI) |
| `WalletChip` | Dashboard header | Compact chip chỉ hiện tên ví + số dư ngắn |
| `SectionHeader` | Toàn bộ app | Title + optional action button, thay thế Padding+Row inline |
| `DateGroupedList` | Transaction List, Saving Goals history | ListView với date separator tự động |
| `PeriodSelector` | Budget, Report | `< Tháng N >` navigation widget |
| `MiniProgressBar` | Dashboard (Budget compact) | 1 dòng text + progress bar nhỏ |
| `XPProgressBar` | AI Coaching, Profile | Level + XP bar theo phong cách gamification |
| `StatBadge` | Profile header | Mini stat (số GD, số ví, v.v.) |
| `SearchBar` | Transaction List | Floating search input |
| `AppSnackBar` | Toàn bộ app | Wrapper chuẩn hóa SnackBar (floating, rounded) |

### Components nên tái sử dụng (đã có, mở rộng thêm)

| Component hiện có | Cần bổ sung |
|---|---|
| `BudgetCard` | Nhận `categoryName: String` thay vì dùng hardcode switch |
| `AppWidgets.emptyState` | Thêm param `onRetry: VoidCallback?` |
| `AppWidgets.appBar` | Thêm param `bottom: PreferredSizeWidget?` cho filter bar |
| `_buildSectionTitle` (AI Coaching) | Tách ra thành global reusable `SectionTitle` widget |

---

## Kết luận

**3 thay đổi có tác động lớn nhất:**

### 1. Dashboard Redesign (Tác động: ★★★★★)
Chuyển từ "trang tổng hợp dài" → "home screen 3 zone":
- Zone A: Sticky greeting header
- Zone B: Hero balance card gọn
- Zone C: Scrollable sections (AI insight compact + budget bar + transaction grouped)

### 2. Date Grouping cho Transaction List (Tác động: ★★★★☆)
Thêm date separator ("Hôm nay", "Hôm qua", "dd/MM") vào ListView — cải thiện khả năng đọc lịch sử giao dịch lên gần như tuyệt đối.

### 3. Period Selector cho Budget & Report (Tác động: ★★★★☆)
Thêm `< Tháng N >` navigation — làm cho 2 màn hình này thực sự có ích (hiện tại chỉ xem được tháng hiện tại).

---

*Tài liệu này là kế hoạch phân tích, không bao gồm code. Thực hiện redesign theo từng sprint đã xác định ở trên.*
