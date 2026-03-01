enum UserRole {
  admin,
  manager,
  cashier;

  // Screen access
  bool get canAccessInventory => true;
  bool get canAccessReports => this != cashier;
  bool get canAccessSettings => this != cashier;

  // Inventory actions
  bool get canAdjustStock => this != cashier;
  bool get canImportCsv => this != cashier;
  bool get canExportCsv => this != cashier;

  // Settings sections
  bool get canAccessCurrencySettings => this == admin;
  bool get canSwitchStore => this == admin;
}
