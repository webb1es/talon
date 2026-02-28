import '../theme/app_theme.dart';

/// Brand voice strings per theme. All user-facing copy goes here.
class AppStrings {
  AppStrings._();

  static const appName = 'Talon™';
  static const tagline = 'Strike fast. Track everything.';

  // Sale complete
  static String saleComplete(AppThemeType theme) => switch (theme) {
    AppThemeType.predator => 'Secured.',
    AppThemeType.precision => 'Verified.',
    AppThemeType.strike => 'Done.',
  };

  // Error
  static String error(AppThemeType theme, String reason) => switch (theme) {
    AppThemeType.predator => 'Halt. $reason',
    AppThemeType.precision => 'Exception: $reason',
    AppThemeType.strike => 'Miss. Try again.',
  };

  // Low stock
  static String lowStock(AppThemeType theme, int count) => switch (theme) {
    AppThemeType.predator => 'Grip low: $count left',
    AppThemeType.precision => 'Threshold reached: $count',
    AppThemeType.strike => 'Running low: $count',
  };

  // Welcome
  static String welcome(AppThemeType theme) => switch (theme) {
    AppThemeType.predator => 'Ready. Set. Strike.',
    AppThemeType.precision => 'System ready.',
    AppThemeType.strike => "Let's go.",
  };

  // Loading
  static String loading(AppThemeType theme) => switch (theme) {
    AppThemeType.predator => 'Gripping data...',
    AppThemeType.precision => 'Calibrating...',
    AppThemeType.strike => 'Loading fast...',
  };

  // Auth
  static const login = 'Log in';
  static const logout = 'Log out';
  static const email = 'Email';
  static const password = 'Password';
  static const role = 'Role';
  static const roleAdmin = 'Admin';
  static const roleManager = 'Manager';
  static const roleCashier = 'Cashier';
  static const emailRequired = 'Email is required';
  static const emailInvalid = 'Enter a valid email';
  static const passwordRequired = 'Password is required';

  // Store
  static const selectStore = 'Select Store';
  static const retry = 'Retry';

  // Navigation
  static const pos = 'POS';
  static const inventory = 'Inventory';
  static const reports = 'Reports';
  static const customers = 'Customers';
  static const settings = 'Settings';
}
