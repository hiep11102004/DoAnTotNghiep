class AppConstants {
  static const String baseUrl = 'http://192.168.0.100:8000/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String userProfile = '/user';
  static const String userSettings = '/user/settings';

  // Feature Endpoints
  static const String wallets = '/wallets';
  static const String transactions = '/transactions';
  static const String transactionsSummary = '/transactions/summary';
  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String savingGoals = '/saving-goals';
  static const String notifications = '/notifications';

  // AI & Gamification
  static const String aiReviews = '/ai/reviews';
  static const String aiTasks = '/ai/tasks';
  static const String badges = '/badges';
  static const String challenges = '/challenges';

  // Reports
  static const String spendingByCategoryReport = '/reports/spending-by-category';
}