class AppConstants {
  static const String baseUrl = 'http://192.168.0.101:8000/api'; 

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

  // Feature Endpoints
  static const String wallets = '/wallets';
  static const String transactions = '/transactions';
  static const String categories = '/categories';
  static const String budgets = '/budgets';
  static const String savingGoals = '/saving-goals';
  static const String aiReviews = '/ai-reviews';
  static const String aiTasks = '/ai-tasks';

  // Reports
  static const String spendingByCategoryReport = '/reports/spending-by-category';
}