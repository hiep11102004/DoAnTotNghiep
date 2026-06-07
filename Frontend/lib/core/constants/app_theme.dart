import 'package:flutter/material.dart';

class AppColors {
  // Primary — xanh lá chủ đạo của app
  static const Color primary = Color(0xFF27AE60);
  static const Color primaryLight = Color(0xFFE8F8F1);
  static const Color primaryDark = Color(0xFF1E8449);
  static const Color primaryMid = Color(0xFF2ECC71);

  // Text
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color textOnPrimary = Colors.white;

  // Background
  static const Color background = Color(0xFFF4F7F6);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFB);

  // Semantic
  static const Color income = Color(0xFF27AE60);
  static const Color expense = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Transaction background badges
  static const Color incomeBg = Color(0xFFE8F8F5);
  static const Color expenseBg = Color(0xFFFCE4D6);
  static const Color warningBg = Color(0xFFFEF9E7);

  // Divider + border
  static const Color divider = Color(0xFFECF0F1);
  static const Color border = Color(0xFFDFE6E9);

  // Shadow (use withOpacity when needed)
  static const Color shadowBase = Color(0xFF000000);
}

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  // Labels & caption
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );

  // Numeric/amounts
  static const TextStyle amount = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  static const TextStyle amountLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );
  static const TextStyle amountIncome = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.income,
  );
  static const TextStyle amountExpense = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.expense,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
  );
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}

class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

/// Các widget helper dùng chung
class AppWidgets {
  /// AppBar chuẩn của app (white bg, title xanh đậm)
  static AppBar appBar({
    required String title,
    bool centerTitle = false,
    bool automaticallyImplyLeading = true,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: centerTitle,
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: AppColors.surface,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }

  /// Empty state widget chuẩn
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.h4, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Card container chuẩn
  static BoxDecoration cardDecoration({double radius = AppRadius.lg}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowBase.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Input decoration chuẩn
  static InputDecoration inputDecoration({
    required String label,
    Widget? prefixIcon,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: AppTextStyles.bodySecondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
    );
  }

  /// Primary button style chuẩn
  static ButtonStyle primaryButtonStyle({double radius = AppRadius.md}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
