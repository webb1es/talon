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

  // Products
  static const allCategories = 'All';
  static const noProducts = 'No products found';
  static const searchProducts = 'Search by name or SKU';

  // Cart
  static const cart = 'Cart';
  static const clearCart = 'Clear';
  static const subtotal = 'Subtotal';
  static const checkout = 'Checkout';
  static const emptyCart = 'Cart is empty';

  // Checkout
  static const tax = 'Tax (15%)';
  static const total = 'Total';
  static const cashTendered = 'Cash tendered';
  static const change = 'Change';
  static const confirmPayment = 'Confirm Payment';
  static const cancel = 'Cancel';
  static const insufficientAmount = 'Amount must cover total';

  // Receipt
  static const receipt = 'Receipt';
  static const print = 'Print';
  static const done = 'Done';
  static const cashier = 'Cashier';
  static const date = 'Date';
  static const cash = 'Cash';

  // Reports
  static const todaysSales = "Today's Sales";
  static const totalSales = 'Total Sales';
  static const transactionCount = 'Transactions';
  static const totalTax = 'Tax Collected';
  static const noTransactions = 'No transactions today';
  static const refresh = 'Refresh';

  // Landing
  static const heroHeadline = 'Complete control.\nComplete confidence.';
  static const heroSubtitle =
      'The POS system built for businesses that mean business.';
  static const getStarted = 'Get Started';
  static const learnMore = 'Learn More';
  static const featurePos = 'Lightning-Fast POS';
  static const featurePosDesc =
      'Ring up sales in seconds. Built for speed, optimized for flow.';
  static const featureOffline = 'Offline-First';
  static const featureOfflineDesc =
      'Works without internet. Syncs automatically when you reconnect.';
  static const featureMultiStore = 'Multi-Store';
  static const featureMultiStoreDesc =
      'Manage multiple locations from a single dashboard.';
  static const featureReports = 'Real-Time Reports';
  static const featureReportsDesc =
      'Sales, tax, and inventory data at your fingertips.';
  static const featureThemes = 'Your Brand, Your Way';
  static const featureThemesDesc =
      'Three distinct themes — Predator, Precision, Strike — each in light and dark.';
  static const featureSecurity = 'Role-Based Security';
  static const featureSecurityDesc =
      'Admin, manager, and cashier roles with granular access control.';
  static const themeShowcase = 'Choose Your Edge';
  static const ctaHeadline = 'Fast. Sharp. Easy.';
  static const ctaSubtitle =
      'Start selling in minutes. No setup fees. No contracts.';

  // One-pager
  static const onePager = 'Product Overview';
  static const onePagerShare = 'Share';
  static const onePagerBenefitSpeed = 'Sub-second checkout';
  static const onePagerBenefitOffline = 'Works 100% offline — syncs when online';
  static const onePagerBenefitMultiStore = 'Multi-store from one dashboard';
  static const onePagerBenefitReports = 'Real-time sales and tax reports';
  static const onePagerBenefitThemes = 'Six branded theme variations';
  static const onePagerBenefitSecurity = 'Role-based access control with RLS';
  static const onePagerBenefitCurrency = 'Multi-currency with live exchange rates';
  static const onePagerBenefitPlatform = 'Runs on mobile, tablet, desktop, and web';
  static const onePagerWhy = 'Why Talon?';
  static const onePagerWhyBody =
      'Talon is built for businesses that need speed, reliability, and control. '
      'No internet? No problem. Every transaction is stored locally and synced '
      'automatically. Manage one store or twenty — same app, same simplicity.';
  static const onePagerContact = 'mytalon.co.zw';

  // Settings
  static const account = 'Account';
  static const theme = 'Theme';
  static const appearance = 'Appearance';
  static const lightMode = 'Light';
  static const darkMode = 'Dark';
  static const predator = 'Predator';
  static const precision = 'Precision';
  static const strike = 'Strike';
  static const switchStore = 'Switch Store';
  static const logoutConfirm = 'Are you sure you want to log out?';

  // Inventory
  static const totalItems = 'items';
  static const lowStockLabel = 'low';
  static const outOfStock = 'out';
  static const stockQuantity = 'Stock quantity';
  static const stockRequired = 'Enter a quantity';
  static const save = 'Save';
  static const sku = 'SKU';

  // Navigation
  static const pos = 'POS';
  static const inventory = 'Inventory';
  static const reports = 'Reports';
  static const customers = 'Customers';
  static const settings = 'Settings';
}
